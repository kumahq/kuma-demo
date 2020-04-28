#/bin/sh

KUMACTL_BIN=${HOME}/bin/kumactl
KUMA_VERSION="0.4.0"

KIND_BIN=${HOME}/bin/kind
KIND_VERSION="v0.8.0"
KIND_CONFIG=./cluster.yaml
KIND_CLUSTER=kuma

KIND_DEMO=../kubernetes/kuma-demo-aio.yaml

ARCH="amd64"

OS="`uname`"
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

BITS="`getconf LONG_BIT`"
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
if [ ! -x "${KIND_BIN}" ] ;  then
  KIND_URL="https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-${OS}-${ARCH}"

  curl --location --create-dirs --output ${KIND_BIN} ${KIND_URL}
  chmod +x ${KIND_BIN}
fi

# Ensure kumactl binary in ${HOME}/bin
if [ ! -x "${KUMACTL_BIN}" ] ;  then

  case $OS in
    'linux')
      OS='ubuntu' # kumactl is a static go binary, default to Ubuntu
      ;;
  esac

  KUMA_URL="https://kong.bintray.com/kuma/kuma-${KUMA_VERSION}-${OS}-${ARCH}.tar.gz"
  curl --location --output - ${KUMA_URL} | tar -z --extract --file=- -C ${HOME} ./bin/kumactl
fi

# Cleanup the created cluster
function cleanup {
  echo "Cleaning up"
  ${KIND_BIN} delete cluster --name ${KIND_CLUSTER}
}
# Call the cleanup function on exit
trap cleanup EXIT

# Kubernetes port forwarding
# $1      - namespace
# $2      - label
# $3 ...  - ports
function portforward() {
    NAMESPACE=$1
    LABEL=$2
    shift; shift # pop the first two arguments off the args stack
    PORTS=$@
    DEMO_APP_POD=$(kubectl get pod -n ${NAMESPACE} -l ${LABEL} -o jsonpath="{.items[0].metadata.name}")
    kubectl port-forward ${DEMO_APP_POD} -n ${NAMESPACE} ${PORTS} &>/dev/null &
}

# Create the kind cluster to host Kuma and the Demo
${KIND_BIN} create cluster --name="${KIND_CLUSTER}" --config ./cluster.yaml --wait 120s
until kubectl taint node ${KIND_CLUSTER}-control-plane node-role.kubernetes.io/master:NoSchedule- ;
do
  echo "Waiting for the cluster to come up" && sleep 3;
done

# Deploy Kuma and wait for the deployment to finish
${KUMACTL_BIN} install control-plane | kubectl apply --wait -f -
kubectl wait -n kuma-system --timeout=300s --for condition=Ready --all pods

# Deploy the Demo and wait for the deployment to finish
kubectl apply --wait -f ${KIND_DEMO}
kubectl wait -n kuma-demo --timeout=300s --for condition=Ready --all pods

# Print the Kuma and Demo pods
kubectl get pods -n kuma-system
kubectl get pods -n kuma-demo

# Portforward to Kuma Control plane and the Demo fronted
portforward kuma-system app=kuma-control-plane 5681 5683
portforward kuma-demo app=kuma-demo-frontend 8080

until curl http://localhost:5681 &> /dev/null ;
do
  echo "Waiting for the port forwarding to finish" && sleep 3;
done

# Run a couple of Kumactl commands
${KUMACTL_BIN} config control-planes add --name=kind --address=http://localhost:5681
${KUMACTL_BIN} inspect dataplanes

echo "Kuma GUI is available at http://localhost:5683/"
echo "Kuma DEMO is available at http://localhost:8080/"

echo "Type 'quit' to exit."
while read line ;
do
  if  echo "$line" | grep -qi "quit"; then
    exit 0;
  fi
done
