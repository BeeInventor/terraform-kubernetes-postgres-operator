VERSION 0.6
FROM mcr.microsoft.com/vscode/devcontainers/base:0-jammy

devcontainer-library-scripts:
    RUN curl -fsSLO https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh
    RUN curl -fsSLO https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-debian.sh
    RUN curl -fsSLO https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/kubectl-helm-debian.sh
    SAVE ARTIFACT --keep-ts *.sh AS LOCAL .devcontainer/library-scripts/

devcontainer:
    FROM DOCKERFILE .devcontainer
    SAVE IMAGE --cache-hint

test:
    FROM +devcontainer
    WORKDIR /workspace
    COPY *.tf .
    COPY submodules submodules
    WORKDIR /workspace/examples/basic
    COPY examples/basic/main.tf .
    COPY .devcontainer/docker-compose.yml .
    RUN terraform init
    ENV KUBECONFIG=kubeconfig.yaml
    ENV KUBECONFIG_PATH=kubeconfig.yaml
    WITH DOCKER --allow-privileged --compose docker-compose.yml \
        --service k3s-server \
        --service k3s-agent
        RUN while ! kubectl get --raw='/readyz'; do sleep 1; done; terraform apply -auto-approve
    END
