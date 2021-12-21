#!/usr/bin/env bash
docker run --rm -it \
-v $(pwd):/app \
-v ~/.ssh/github_akijowski_mbp13:/root/.ssh/github_akijowski_mbp13 \
-v ~/.ssh/known_hosts:/root/.ssh/known_hosts \
-v ~/.kube:/root/.kube \
helm-local
