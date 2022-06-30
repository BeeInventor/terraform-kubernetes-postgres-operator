VERSION 0.6
FROM mcr.microsoft.com/vscode/devcontainers/base:0-jammy

devcontainer-library-scripts:
    RUN curl -fsSLO https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/common-debian.sh
    RUN curl -fsSLO https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/docker-debian.sh
    RUN curl -fsSLO https://raw.githubusercontent.com/microsoft/vscode-dev-containers/main/script-library/kubectl-helm-debian.sh
    SAVE ARTIFACT --keep-ts *.sh AS LOCAL .devcontainer/library-scripts/

# Usage:
# COPY +tfk8s/tfk8s /usr/local/bin/
tfk8s:
    FROM golang:1.17
    RUN go install github.com/jrhouston/tfk8s@v0.1.7
    SAVE ARTIFACT /go/bin/tfk8s

crds:
    FROM +devcontainer
    WORKDIR /workspace
    COPY +tfk8s/tfk8s /usr/local/bin/
    COPY submodules/postgres-operator/helm/install/crds/*.yaml .
    RUN find . -name '*.yaml' -exec tfk8s --strip --file {} --output {}.tf \;
    SAVE ARTIFACT --keep-ts *.tf AS LOCAL ./crds/

devcontainer:
    FROM DOCKERFILE .devcontainer
    SAVE IMAGE --cache-hint

test:
    BUILD +test-basic

test-basic:
    FROM +devcontainer
    WORKDIR /workspace
    COPY *.tf .
    COPY crds crds
    COPY submodules submodules
    WORKDIR /workspace/examples/basic
    COPY examples/basic/*.tf .
    COPY .devcontainer/docker-compose.yml .
    RUN terraform init
    ENV KUBECONFIG=kubeconfig.yaml
    ENV KUBE_CONFIG_PATH=kubeconfig.yaml
    WITH DOCKER --allow-privileged --compose docker-compose.yml --service k3s-server
        RUN while ! kubectl get --raw='/readyz'; do sleep 1; done; \
            terraform apply -auto-approve -target module.postgres-operator \
            && terraform apply -auto-approve
    END
