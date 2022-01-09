#!/usr/bin/env bash

function build_image() {
    readonly name=$1

    docker build -f helm.Dockerfile -t $name .
}

build_image helm-local