
# CircleCI docker image to run within
FROM cimg/base:stable
# Base image uses "circleci", to avoid using `sudo` run as root user
USER root

# install awscliv2, disable default pager (less)
ENV AWS_PAGER=""
ARG AWSCLI_VERSION=2.0.37
COPY sigs/awscliv2_pgp.key /tmp/awscliv2_pgp.key
RUN gpg --import /tmp/awscliv2_pgp.key
RUN set -ex && cd ~ \
    && curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o awscliv2.zip \
    && curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip.sig" -o awscliv2.sig \
    && gpg --verify awscliv2.sig awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install --update \
    && aws --version \
    && rm -r awscliv2.zip awscliv2.sig aws

ARG AWS_NUKE_VERSION=2.15.0
ARG AWS_NUKE_SHA256SUM=2b6cf01c978d1581341e9612107a217826ae9bce0529f41a839fedae47f9e8d2
RUN set -ex && cd ~ \
    && curl -sSLO https://github.com/rebuy-de/aws-nuke/releases/download/v${AWS_NUKE_VERSION}/aws-nuke-v${AWS_NUKE_VERSION}-linux-amd64.tar.gz \
    && [ $(sha256sum aws-nuke-v${AWS_NUKE_VERSION}-linux-amd64.tar.gz | cut -f1 -d' ') = ${AWS_NUKE_SHA256SUM} ] \
    && chmod 755 aws-nuke-v${AWS_NUKE_VERSION}-linux-amd64.tar.gz \
    && mv aws-nuke-v${AWS_NUKE_VERSION}-linux-amd64.tar.gz /usr/local/bin/aws-nuke

# apt-get all the things
# Notes:
# - Add all apt sources first
# - groff and less required by AWS CLI
ARG CACHE_APT
RUN set -ex && cd ~ \
    && apt-get update \
    && : Install apt packages \
    && apt-get -qq -y install --no-install-recommends apt-transport-https less groff lsb-release \
    && : Cleanup \
    && apt-get clean \
    && rm -vrf /var/lib/apt/lists/*

USER circleci
