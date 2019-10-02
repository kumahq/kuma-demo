// minikube (k8s must be 1.15 or higher)
$ minikube start --kubernetes-version v1.15.4

// get latest 0.2 Kuma
$ wget -o kuma-0.2.0-rc2.tar.gz https://bintray.com/kong/kuma/download_file?file_path=kuma-0.2.0-rc2-darwin-amd64.tar.gz

// extract 
$ tar xvzf kuma-0.2.0-rc2.tar.gz

//move to bin and list 
$ cd bin && ls
envoy   kuma-cp   kuma-dp   kuma-tcp-echo kumactl

//install and run kuma
$ kumactl install control-plane | kubectl apply -f -

//check kuma-system namespace
$ kubectl get pods -n kuma-system

//install db
$ kubectl apply -f kuma-demo-db.yaml

//check db is up
$ kubectl get pods -n kuma-app

//install api server and front-end app
$ kubectl apply -f kuma-demo-app.yaml

//curl to post fake data into databases
kubectl exec -ti POD_NAME -c kuma-demo-api -n kuma-app -- curl -XPOST http://localhost:3001/upload
//like this 
kubectl exec -ti kuma-demo-api-847598db54-llmfk -c kuma-demo-api -n kuma-app -- curl -XPOST http://localhost:3001/upload

//port forward frontend
kubectl port-forward POD_NAME -n kuma-app 8080:8080 3001:3001
//like this
kubectl port-forward kuma-demo-api-847598db54-llmfk -n kuma-app 8080:8080 3001:3001

//go to page
http://localhost:8080/

//apply policies (3 in 1 file)
$ kubectl apply -f kuma-demo-policy.yaml

//refresh localhost:8080


