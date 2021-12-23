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

function uninstall_manifests() {
    pushd ./kube-prometheus
    kubectl delete --ignore-not-found=true -f manifests/ -f manifests/setup
    popd ./kube-prometheus
}

function remove_the_thing() {
    clone_repo
    uninstall_manifests
}

remove_the_thing
