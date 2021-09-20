#! /usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

readonly HERE="$(cd $(dirname "$0") && pwd)"

readonly KUMACTL_BIN="${HOME}/bin/kumactl"
readonly KIND_BIN="${HOME}/bin/kind"

readonly KIND_VERSION="v0.11.1"
KUMA_VERSION=${KUMA_VERSION:-""}

readonly KIND_CONFIG="${HERE}/cluster.yaml"
readonly KIND_CLUSTER="kuma-demo"

readonly KIND_KUBECONFIG_DIR="${HOME}/.kube"
readonly KIND_KUBECONFIG="${KIND_KUBECONFIG_DIR}/kind-${KIND_CLUSTER}-config"

readonly KIND_DEMO="${HERE}/../kubernetes/kuma-demo-aio.yaml"

readonly KUBECTL=kubectl

ARCH="amd64"

OS="$(uname)"
case $OS in
  'Linux')
    OS='linux'
    ;;
  'Darwin')
    OS='darwin'
    ;;
  *)
    echo "$OS not supported"
    exit 1
    ;;
esac

BITS="$(getconf LONG_BIT)"
case $BITS in
  '64')
    echo "64-bit platform found"
    ;;
  *)
    echo "$BITS platform not supported"
    exit 1
    ;;
esac

# Ensure kind binary in ${HOME}/bin
if [ ! -x "${KIND_BIN}" ] || [ "$(${KIND_BIN} version | awk '{ print $2}')" != "${KIND_VERSION}" ] ;  then
  echo "Installing Kind ${KIND_VERSION}"

  KIND_URL="https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-${OS}-${ARCH}"

  curl --progress-bar --location --create-dirs --output "${KIND_BIN}" ${KIND_URL}
  chmod +x "${KIND_BIN}"
fi

# Ensure kumactl binary in ${HOME}/bin
if [ -z "${KUMA_VERSION}" ]; then
    KUMA_VERSION=$(curl --silent https://kuma.io/latest_version)
fi

if [ ! -x "${KUMACTL_BIN}" ] || ! grep -q "${KUMA_VERSION}" <(${KUMACTL_BIN} version 2>&1) ;  then

  case $OS in
    'linux')
      OS='ubuntu' # kumactl is a static go binary, default to Ubuntu
      ;;
  esac

  (
    cd $(mktemp -d)

    curl --silent https://kuma.io/installer.sh | VERSION="$KUMA_VERSION" bash

    mkdir -p "$(dirname ${KUMACTL_BIN})"
    cp $(find . -name kumactl) "${KUMACTL_BIN}"

  )
fi

# Cleanup the created cluster
cleanup() {
  echo "Cleaning up"
  ${KIND_BIN} delete cluster --name ${KIND_CLUSTER}
}
# Call the cleanup function on exit
trap cleanup EXIT

# Kubernetes port forwarding
# $1      - namespace
# $2      - label
# $3 ...  - ports
portforward() {
    NAMESPACE=$1
    LABEL=$2
    shift; shift # pop the first two arguments off the args stack
    PORTS=$@
    DEMO_APP_POD=$(${KUBECTL} get pod -n "${NAMESPACE}" -l "${LABEL}" -o jsonpath="{.items[0].metadata.name}")
    KUBECONFIG=${KIND_KUBECONFIG} ${KUBECTL} port-forward "${DEMO_APP_POD}" -n "${NAMESPACE}" ${PORTS} >/dev/null 2>&1 &
}

# Create the kind cluster to host Kuma and the Demo; Ensure the controller can be used as a worker node too
${KIND_BIN} create cluster --name="${KIND_CLUSTER}" \
            --config "${KIND_CONFIG}" \
            --kubeconfig "${KIND_KUBECONFIG}" \
            --wait 120s

export KUBECONFIG=${KIND_KUBECONFIG}

until ${KUBECTL} taint node ${KIND_CLUSTER}-control-plane node-role.kubernetes.io/master:NoSchedule- ;
do
  echo "Waiting for the cluster to come up" && sleep 3;
done

# Deploy Kuma and wait for the deployment to finish. Waiting for pods
# immediately is racy because if no pod resources are present when kubectl
# runs, it will error out. This is why we wait for some initial deployment
# availability first.
${KUMACTL_BIN} install control-plane | ${KUBECTL} apply --wait -f -
${KUBECTL} wait -n kuma-system --timeout=300s --for condition=Available --all deployments
${KUBECTL} wait -n kuma-system --timeout=300s --for condition=Ready --all pods

# Deploy the Demo and wait for the deployment to finish.
${KUBECTL} apply --wait -f ${KIND_DEMO}
${KUBECTL} wait -n kuma-demo --timeout=300s --for condition=Available --all deployments
${KUBECTL} wait -n kuma-demo --timeout=300s --for condition=Ready --all pods

# Print the Kuma and Demo pods
${KUBECTL} get pods -n kuma-system
${KUBECTL} get pods -n kuma-demo

# Portforward to Kuma Control plane and the Demo fronted
portforward kuma-system app=kuma-control-plane 5681
portforward kuma-demo app=kuma-demo-frontend 8080

until curl --silent http://localhost:5681 >/dev/null 2>&1 ;
do
  echo "Waiting for the port forwarding to finish" && sleep 3;
done

# Run a couple of Kumactl commands
${KUMACTL_BIN} config control-planes add --overwrite --name=kind --address=http://localhost:5681
${KUMACTL_BIN} inspect dataplanes

echo
printf "Kuma GUI is available at \033[0;33mhttp://localhost:5681/gui\033[0m  ⬅️\n"
printf "Kuma DEMO is available at \033[0;33mhttp://localhost:8080/\033[0m  ⬅️\n"
echo
printf "For more about Integrations and Metrics see \033[0;33mhttps://github.com/kumahq/kuma-demo/tree/master/kubernetes#integrations\033[0m\n"
echo
printf "To see Kuma in action, follow the Policies guidelines \033[0;33mhttps://github.com/kumahq/kuma-demo/tree/master/kubernetes#policies\033[0m\n"
echo
echo "🛑 Before using kubectl, please run the following in your shell:"
echo
echo "export KUBECONFIG=${KIND_KUBECONFIG}"
echo
echo "Type 'quit' to exit."
while read -r line ;
do
  if  echo "$line" | grep -qi "quit"; then
    exit 0;
  fi
done
