FROM alpine:3.9

ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.name="helm-kubectl" \
      org.label-schema.url="https://hub.docker.com/r/dtzar/helm-kubectl/" \
      org.label-schema.vcs-url="https://github.com/dtzar/helm-kubectl" \
      org.label-schema.build-date=$BUILD_DATE

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ENV KUBE_LATEST_VERSION="v1.14.3"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.14.1"
# Note: Latest version of krew may be found at:
# https://github.com/kubernetes-sigs/krew/releases
ENV KREW_VERSION="v0.2.1"

RUN apk add --no-cache ca-certificates bash git openssh curl ncurses python which bash \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && git clone https://github.com/ahmetb/kubectx /opt/kubectx \
    && git clone https://github.com/johanhaleby/kubetail.git /opt/kubetail \
    && ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx \
    && chmod +x /usr/local/bin/kubectx \
    && ln -s /opt/kubectx/kubens /usr/local/bin/kubens \ 
    && chmod +x /usr/local/bin/kubens \
    && ln -s /opt/kubetail/kubetail /usr/local/bin/kubetail \
    && chmod +x /usr/local/bin/kubetail \
    && set -x; cd "$(mktemp -d)" \
    && curl -fsSLO "https://storage.googleapis.com/krew/${KREW_VERSION}/krew.{tar.gz,yaml}" \
    && tar zxvf krew.tar.gz \
    && ./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" install --manifest=krew.yaml --archive=krew.tar.gz \
    && curl -sSL https://sdk.cloud.google.com | bash

ENV PATH="${KREW_ROOT:-$HOME/.krew}/bin:${PATH}"
ENV PATH $PATH:/root/google-cloud-sdk/bin

WORKDIR /config

CMD bash
