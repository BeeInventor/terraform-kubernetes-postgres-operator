FROM mcr.microsoft.com/vscode/devcontainers/base:0-jammy

ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG USE_MOBY="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG ENABLE_NONROOT_DOCKER="true"
ARG KUBECTL_VERSION="1.21.12"
ARG HELM_VERSION="latest"
ARG MINIKUBE_VERSION="none"
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" "${USE_MOBY}" \
    && /bin/bash /tmp/library-scripts/kubectl-helm-debian.sh "$KUBECTL_VERSION" "$HELM_VERSION" "$MINIKUBE_VERSION" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

ARG TARGETARCH

RUN apt-get update \
    && apt-get -yqq install --no-install-recommends \
        bash-completion \
        jq \
        direnv \
        software-properties-common \
        docker-ce \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install psql
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
    && echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get -yqq install --no-install-recommends \
        postgresql-client-13 \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install earthly
RUN curl -fsSL https://github.com/earthly/earthly/releases/download/v0.6.14/earthly-linux-${TARGETARCH} -o /usr/local/bin/earthly \
    && chmod +x /usr/local/bin/earthly
RUN earthly bootstrap --no-buildkit --with-autocomplete

# Install tfenv
RUN git clone --depth 1 https://github.com/tfutils/tfenv.git /tfenv \
    && ln -s /tfenv/bin/* /usr/local/bin
ARG TERRAFORM_VERSION=1.2.1
RUN tfenv install "$TERRAFORM_VERSION"
RUN tfenv use "$TERRAFORM_VERSION"

# Install Terraform Language Server
ARG TERRAFORM_LS_VERSION=0.27.0
RUN curl -fsSL -o terraform-ls.zip https://github.com/hashicorp/terraform-ls/releases/download/v${TERRAFORM_LS_VERSION}/terraform-ls_${TERRAFORM_LS_VERSION}_linux_${TARGETARCH}.zip \
    && unzip -qq terraform-ls.zip \
    && mv ./terraform-ls /usr/local/bin/ \
    && rm terraform-ls.zip

# Config bash completion
RUN echo 'complete -C terraform terraform' >> /home/$USERNAME/.bashrc \
    && echo 'source <(kubectl completion bash)' >> /home/$USERNAME/.bashrc \
    && echo 'source <(helm completion bash)' >> /home/$USERNAME/.bashrc

# Config direnv
COPY --chown=$USER_UID:$USER_GID ./direnv.toml /home/$USERNAME/.config/direnv/config.toml
RUN echo 'eval "$(direnv hook bash)"' >> /home/$USERNAME/.bashrc
