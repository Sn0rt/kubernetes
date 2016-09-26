#!/bin/bash

pushd $GOPATH/src/github.com/kubernetes/kubernetes/
run() {
	export ALLOW_PRIVILEGED=true
	export NETWORK_POLICY_PROVIDER=calico
	export PATH=${PATH}:/root/workspace/go/src/github.com/kubernetes/kubernetes/third_party/etcd 
	export RUNTIME_CONFIG="extensions/v1beta1=true,extensions/v1beta1/thirdpartyresources=true"
	hack/local-up-cluster.sh 

}

if [ -e /root/workspace/go/src/github.com/kubernetes/kubernetes/third_party/etcd ]; then
	run
else 
	hack/install-etcd.sh
	run
fi
popd
