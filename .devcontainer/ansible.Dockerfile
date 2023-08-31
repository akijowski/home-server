FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu-22.04

RUN apt-get update -y && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y software-properties-common \
    python3-pip \
    curl \
    vim \
    && apt-get autoremove \
    && apt-get purge \
    && apt-get clean

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN python3 -m pip install ansible --no-cache-dir

RUN python3 -m pip install argcomplete --no-cache-dir

RUN activate-global-python-argcomplete

RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

RUN mkdir -p /etc/ansible/roles

RUN chmod -R 0777 /etc/ansible/
