FROM public.ecr.aws/docker/library/ubuntu:resolute

ARG DEBIAN_FRONTEND="noninteractive"

RUN set -ex \
  && echo "installing base" \
  && apt-get update \
  && apt-get install --assume-yes --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  && echo "installing tools" \
  && apt-get install --assume-yes --no-install-recommends \
  amazon-ecr-credential-helper \
  awscli \
  docker.io \
  file \
  gcc \
  git \
  golang \
  hugo \
  jq \
  make \
  nodejs \
  npm \
  openjdk-21-jdk \
  openssh-client \
  perl \
  podman \
  python3 \
  python3-pip \
  rustc-1.91 \
  rsync \
  sed \
  wget \
  && echo "install tofu" \
  && curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o /tmp/install-opentofu.sh \
  && chmod 755 /tmp/install-opentofu.sh \
  && /tmp/install-opentofu.sh --install-method deb \
  && echo "clean up" \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists \
  && rm /tmp/install-opentofu.sh \
  && echo "done"
