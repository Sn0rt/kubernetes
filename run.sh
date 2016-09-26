#!/bin/bash

#make WAHT=cmd/kubectl 

trap clear SIGINT

ready() {
	export KUBERNETES_PROVIDER=local
	cluster/kubectl.sh config set-cluster local --server=http://127.0.0.1:8080 --insecure-skip-tls-verify=true
	cluster/kubectl.sh config set-context local --cluster=local
	cluster/kubectl.sh config use-context local
	_output/bin/kubectl get node
	curl localhost:8080/apis/extensions/v1beta1/networkpolicies
}


start() {
	kubectl apply -f calico.yaml --validate=false
	_output/bin/kubectl --namespace=default run nginx --image=nginx --replicas=2
	_output/bin/kubectl --namespace=default expose deployment nginx --port=80 
	sleep 3
	_output/bin/kubectl --namespace=default get svc,pod 
}

test() {
	curl localhost:8080/apis/extensions/v1beta1/networkpolicies
	_output/bin/kubectl --namespace=default run busybox --rm -ti --image=docker.io/busybox /bin/sh # wget -s --timeout=1 10.0.0.2
}

policy() {
	_output/bin/kubectl annotate ns default "net.beta.kubernetes.io/network-policy={\"ingress\": {\"isolation\": \"DefaultDeny\"}}" --overwrite
	cat network-policy.yaml
	_output/bin/kubectl --namespace=default create -f network-policy.yaml --validate=false
}


verify() {
	curl localhost:8080/apis/extensions/v1beta1/networkpolicies
	_output/bin/kubectl --namespace=default run busybox --rm -ti --image=docker.io/busybox /bin/sh # wget -s --timeout=1 10.0.0.2
}

clear() {
	_output/bin/kubectl --namespace=default delete deployments nginx
	_output/bin/kubectl delete svc nginx
}

main() {
	ready
	start	
	test
	policy
	verify
	clear
}

main
