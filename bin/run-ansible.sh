#!/usr/bin/env bash

# https://github.com/willhallonline/docker-ansible

docker run --rm -it \
-v $(pwd)/ansible:/ansible \
-v ~/.ssh/github_akijowski_mbp14:/root/.ssh/github_akijowski_mbp14 \
-v ~/.ssh/known_hosts:/root/.ssh/known_hosts \
ansible-local

#
# mkdir -p ~/.ssh && \
# touch ~/.ssh/known_hosts && \
# echo -e "Adding 192.168.11.6 to known_hosts" && \
# ssh-keyscan -H 192.168.11.6 >> ~/.ssh/known_hosts

#ansible-playbook samba/01_initialize.yml -i hosts -l samba -u adam --private-key /root/.ssh/github_akijowski_mbp13 -K

# ansible-galaxy install -r requirements.yml

# pip3 install cryptography
# apk add py-cryptography
# apk add --no-cache tar
