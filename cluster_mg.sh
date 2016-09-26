#!/bin/bash

iptables -F
iptables -Z
iptables -X

export KUBERNETES_PROVIDER=vagrant
export KUBERNETES_VAGRANT_USE_NFS=true
export ALLOW_PRIVILEGED=true
export NETWORK_POLICY_PROVIDER=calico
export VAGRANT_HTTP_PROXY=http://fnststack:9324864771@10.0.58.88:8080
export VAGRANT_HTTPS_PROXY=http://fnststack:9324864771@10.0.58.88:8080

install() {
	rpm -qa | grep vagrant-libvirt
	if [ $? != 0 ]; then
		dnf install vagrant-libvirt -y
	fi
	pushd $GOPATH/src/github.com/kubernetes/kubernetes
		./cluster/kube-up.sh
	popd
	exit 0	
}

remove() {
	sudo virsh destroy kubernetes_master
	sudo virsh destroy kubernetes_node-1
	sudo virsh undefine kubernetes_master
	sudo virsh undefine kubernetes_node-1
	sudo rm -rf /var/lib/libvirt/images/kubernetes_*
	sudo rm -rf /var/lib/libvirt/qemu/
	sudo rm -rf /var/lib/libvirt/dnsmasq/
	sudo systemctl restart libvirtd.service
	exit 0
}

down() {
	./cluster/kube-down.sh
	exit 0
}

$1

echo "please input $0 install or $0 remove"
