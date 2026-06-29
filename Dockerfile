FROM public.ecr.aws/docker/library/ubuntu:26.04

ARG DEBIAN_FRONTEND="noninteractive"

ENV PATH="/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin:$PATH"

RUN set -ex \
  # phase 1
  && echo "installing base" \
  && apt-get update \
  && apt-get install --assume-yes \
  apt-transport-https \
  ca-certificates \
  gnupg \
  # phase 2
  && echo "installing system" \
  && apt-get install --assume-yes \
  acl \
  # amazon-ecr-credential-helper \
  # ant \
  apt-file \
  apt-utils \
  aria2 \
  autoconf \
  automake \
  # awscli \
  bash \
  bison \
  brotli \
  build-essential \
  bzip2 \
  # ca-certificates-java \
  # cargo \
  # composer \
  coreutils \
  curl \
  # docker-compose-v2 \
  # docker.io \
  # dotnet-sdk-10.0 \
  # eza \
  # fd-find \
  # ffmpeg \
  file \
  # firefox \
  # fzf \
  gcc \
  gettext \
  git \
  gnu-coreutils \
  # golang \
  # gradle \
  groff \
  # grunt \
  gzip \
  haveged \
  # httpie \
  # httpie-aws-authv4 \
  # hugo \
  # hunspell \
  # hunspell-en-us \
  # imagemagick \
  # jq \
  less \
  # lua5.5 \
  # luarocks \
  lz4 \
  m4 \
  make \
  # maven \
  net-tools \
  # node-corepack \
  # nodejs \
  # npm \
  # openjdk-26-jdk \
  # openssh-client \
  openssl \
  # oras \
  patch \
  # perl \
  # php \
  pkg-config \
  # podman \
  # podman-compose \
  # python3 \
  # python3-pip \
  # rake \
  # rbenv \
  rsync \
  # ruby \
  # runc \
  # rustc-1.91 \
  sed \
  software-properties-common \
  sudo \
  tar \
  # tcl9.0 \
  # tcl9.0-dev \
  tcsh \
  # testssl.sh \
  time \
  # tk9.0 \
  tree \
  tzdata \
  # webpack \
  wget \
  # xvfb \
  xz-utils \
  # yarnpkg \
  zip \
  zsh \
  # phase 3
  && echo "clean up" \
  && apt-get clean \
  && rm -rf /usr/share/doc \
  && rm -rf /usr/share/man \
  && rm -rf /var/lib/apt/lists \
  && echo "all done!"

RUN set -ex \
  && echo "install homebrew" \
  && curl \
  --fail \
  --location 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' \
  --output '/tmp/install-homebrew.sh' \
  --proto '=https' \
  --show-error \
  --silent \
  --tlsv1.2 \
  && chmod 0755 /tmp/install-homebrew.sh \
  && /tmp/install-homebrew.sh \
  && echo "brew install packages" \
  && brew install --verbose \
  # ant \
  awscli \
  checkov \
  # composer \
  detect-secrets \
  docker-credential-helper-ecr \
  # dotnet \
  exiftool \
  eza \
  fd \
  # firefox \
  # ffmpeg-full \
  fzf \
  # gcc \
  git-remote-codecommit \
  golang \
  golangci-lint \
  # gradle \
  hadolint \
  # httpie \
  hugo \
  imagemagick-full \
  jq \
  kics \
  license-eye \
  # lua \
  # luarocks \
  # maven \
  node \
  npm \
  opa \
  # openjdk \
  opentofu \
  oras \
  # perl \
  # php \
  podman \
  podman-compose \
  python \
  # ruby \
  # rust \
  rsync \
  # stylua \
  # tcl-tk \
  terraform-docs \
  testssl \
  terraform-linters/tap/tflint \
  tfsec \
  trivy \
  # uv \
  # webpack \
  && echo "clean up" \
  && apt-get clean \
  && brew cleanup --scrub --verbose \
  && rm -rf /home/linuxbrew/.linuxbrew/share/man \
  && rm -rf /root/.cache/Homebrew \
  && rm -rf /tmp/install-homebrew.sh \
  && rm -rf /usr/share/doc \
  && rm -rf /usr/share/man \
  && rm -rf /var/lib/apt/lists \
  && echo "all done!"

COPY rootfs /

RUN set -ex \
  && echo "install extras" \
  && mkdir -p /home/ubuntu/.cache/opentofu/plugin-cache \
  && mkdir -p /home/ubuntu/.config/opentofu \
  && mkdir -p /home/ubuntu/.npm \
  && chmod 755 /home \
  && chown -R ubuntu:ubuntu /home/ubuntu \
  && find /home/ubuntu -type d -exec chmod 700 {} \; \
  && find /home/ubuntu -type f -exec chmod 600 {} \; \
  && echo 'ubuntu ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
  # && echo "brew extras" \
  # && brew install --verbose \
  # fixme \
  && echo "npm extras" \
  && npm install --global \
  @lhci/cli \
  html-validate \
  npm-check-updates \
  && echo "tofu extras" \
  && tofu -chdir=/home/ubuntu init \
  && echo "clean up" \
  && apt-get clean \
  && brew cleanup --scrub --verbose \
  && rm -rf /home/linuxbrew/.linuxbrew/share/man \
  && rm -rf /root/.cache/Homebrew \
  && rm -rf /tmp/install-homebrew.sh \
  && rm -rf /usr/share/doc \
  && rm -rf /usr/share/man \
  && rm -rf /var/lib/apt/lists \
  && chown -R ubuntu:ubuntu /home/ubuntu \
  && find /home/ubuntu -type d -exec chmod 700 {} \; \
  && find /home/ubuntu -type f -exec chmod 600 {} \; \
  && echo "all done!"

ENV KICS_LIBRARIES_PATH=/home/linuxbrew/.linuxbrew/share/kics/assets/libraries
ENV KICS_QUERIES_PATH=/home/linuxbrew/.linuxbrew/share/kics/assets/queries

USER ubuntu
ENV HOME=/home/ubuntu
ENV XDG_CACHE_HOME="/home/ubuntu/.cache"
ENV XDG_CONFIG_HOME="/home/ubuntu/.config"
ENV XDG_DATA_HOME="/home/ubuntu/.local/share"
ENV XDG_STATE_HOME="/home/ubuntu/.local/state"
WORKDIR /home/ubuntu

