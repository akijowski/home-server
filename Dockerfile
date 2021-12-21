FROM hashicorp/terraform:1.1.1 AS terraform-cli

FROM bitnami/kubectl:1.23.1 AS kubectl

FROM ubuntu:focal AS base

# Copy terraform
COPY --from=terraform-cli /bin/terraform /usr/local/bin/terraform

# Copy kubectl
COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl

# Install helm
# https://helm.sh/docs/intro/install/
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

RUN mkdir /app
WORKDIR /app

ENTRYPOINT [ "/usr/bin/bash" ]
