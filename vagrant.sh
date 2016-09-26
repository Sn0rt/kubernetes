#!/bin/bash

export KUBERNETES_PROVIDER=vagrant
export KUBERNETES_VAGRANT_USE_NFS=true
export VAGRANT_HTTP_PROXY=http:/username:password@10.0.58.88:8080
export VAGRANT_HTTPS_PROXY=http://username:password@10.0.58.88:8080
iptables -X
iptables -F
iptables -Z

install() {
    rpm -qa | grep vagrant-libvirt
    if [ $? != 0 ]; then
        dnf install vagrant-libvirt -y
    fi
    vagrant plugin install vagrant-proxyconf # 让vagrant支持的代理的插件
    pushd $GOPATH/src/github.com/kubernetes/kubernetes
    ./cluster/kube-up.sh
    popd
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
}

$1
