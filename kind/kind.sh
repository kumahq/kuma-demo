#!/bin/sh

KUMACTL_BIN=${HOME}/bin/kumactl
KUMA_VERSION="0.5.0"

KIND_BIN=${HOME}/bin/kind
KIND_VERSION="v0.8.1"
KIND_CONFIG=./cluster.yaml
KIND_CLUSTER=kuma

KIND_KUBECONFIG_DIR=${HOME}/.kube
KIND_KUBECONFIG=${KIND_KUBECONFIG_DIR}/kind-kuma-config

KIND_DEMO=../kubernetes/kuma-demo-aio.yaml

KUBECTL=kubectl

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

  curl --location --create-dirs --output "${KIND_BIN}" ${KIND_URL}
  chmod +x "${KIND_BIN}"
fi

# Ensure kumactl binary in ${HOME}/bin
if [ ! -x "${KUMACTL_BIN}" ] || [ "$(${KUMACTL_BIN} version 2>&1)" != "${KUMA_VERSION}" ];  then

  case $OS in
    'linux')
      OS='ubuntu' # kumactl is a static go binary, default to Ubuntu
      ;;
  esac

  KUMA_URL="https://kong.bintray.com/kuma/kuma-${KUMA_VERSION}-${OS}-${ARCH}.tar.gz"
  curl --location --output - ${KUMA_URL} | tar -z --strip 2 --extract --file=- -C "${HOME}" ./kuma-${KUMA_VERSION}/bin/kumactl
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

# Deploy Kuma and wait for the deployment to finish
${KUMACTL_BIN} install control-plane | ${KUBECTL} apply --wait -f -
${KUBECTL} wait -n kuma-system --timeout=300s --for condition=Ready --all pods

# Deploy the Demo and wait for the deployment to finish
${KUBECTL} apply --wait -f ${KIND_DEMO}
${KUBECTL} wait -n kuma-demo --timeout=300s --for condition=Ready --all pods

# Print the Kuma and Demo pods
${KUBECTL} get pods -n kuma-system
${KUBECTL} get pods -n kuma-demo

# Portforward to Kuma Control plane and the Demo fronted
portforward kuma-system app=kuma-control-plane 5681 5683
portforward kuma-demo app=kuma-demo-frontend 8080

until curl http://localhost:5681 >/dev/null 2>&1 ;
do
  echo "Waiting for the port forwarding to finish" && sleep 3;
done

# Run a couple of Kumactl commands
${KUMACTL_BIN} config control-planes add --overwrite --name=kind --address=http://localhost:5681
${KUMACTL_BIN} inspect dataplanes

echo
printf "Kuma GUI is available at \033[0;33mhttp://localhost:5683/\033[0m  ⬅️\n"
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
