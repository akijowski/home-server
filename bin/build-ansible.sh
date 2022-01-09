#!/usr/bin/env bash

function build_image() {
    readonly name=$1

    docker build -f ansible.Dockerfile -t $name .
}

build_image ansible-local