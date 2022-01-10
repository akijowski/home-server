ARG imageVersion=2.10-alpine-3.13
FROM willhallonline/ansible:${imageVersion}

# Install Roles
COPY ansible/requirements.yml /ansible/
RUN ansible-galaxy install -r requirements.yml

ENTRYPOINT [ "/bin/sh" ]