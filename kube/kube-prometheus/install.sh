#!/usr/bin/env bash

set -e

function clone_repo() {
    if [[ ! -d ./kube-prometheus ]]
    then
        echo -e "Cloning repo"
        git clone https://github.com/prometheus-operator/kube-prometheus.git
    else
        echo -e "Repo exists"
    fi
}

function install_setup_manifests() {
    pushd ./kube-prometheus
    # Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
    kubectl apply --server-side -f manifests/setup
    until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
    popd
}

function install_manifests() {
    pushd ./kube-prometheus
    kubectl apply -f manifests/
    popd
}

function do_the_thing() {
    clone_repo
    install_setup_manifests
    install_manifests
}

do_the_thing
