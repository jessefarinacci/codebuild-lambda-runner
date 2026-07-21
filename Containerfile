FROM public.ecr.aws/docker/library/ubuntu:26.04

ARG DEBIAN_FRONTEND="noninteractive"

ENV PATH="/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin:$PATH"
ENV TF_PLUGIN_CACHE_DIR="/home/ubuntu/.cache/opentofu/plugin-cache"

COPY rootfs/opt/extras/homebrew/install.sh /opt/extras/homebrew/install.sh
COPY rootfs/opt/extras/opentofu/main.tf /opt/extras/opentofu/main.tf

# apt-get --option Debug::pkgAcquire::Worker=1 install
# brew install --verbose

RUN \
  --mount=type=cache,target=/root/.cache \
  --mount=type=cache,target=/var/cache \
  --mount=type=cache,target=/var/lib/apt \
  set -ex \
  && echo "installing OS base" \
  && apt-get update \
  && apt-get install --assume-yes \
  apt-transport-https \
  ca-certificates \
  gnupg \
  && echo "installing OS system" \
  && apt-get install --assume-yes \
  acl \
  amazon-ecr-credential-helper \
  ant \
  apt-file \
  apt-utils \
  aria2 \
  autoconf \
  automake \
  awscli \
  bash \
  bison \
  brotli \
  build-essential \
  bzip2 \
  ca-certificates-java \
  cargo \
  coreutils \
  curl \
  docker-compose-v2 \
  docker.io \
  eza \
  fd-find \
  ffmpeg \
  file \
  # firefox \
  fzf \
  gcc \
  gettext \
  git \
  gnu-coreutils \
  golang \
  gradle \
  groff \
  grunt \
  gzip \
  haveged \
  httpie \
  httpie-aws-authv4 \
  hugo \
  hunspell \
  hunspell-en-us \
  imagemagick \
  jq \
  less \
  lua5.5 \
  luarocks \
  lz4 \
  m4 \
  make \
  maven \
  net-tools \
  node-corepack \
  nodejs \
  npm \
  openjdk-25-jdk \
  openssh-client \
  openssl \
  oras \
  patch \
  perl \
  pkg-config \
  podman \
  podman-compose \
  python3 \
  python3-pip \
  rsync \
  runc \
  rustc-1.93 \
  sed \
  software-properties-common \
  sudo \
  tar \
  tcsh \
  testssl.sh \
  time \
  tree \
  tzdata \
  # webpack \
  wget \
  xvfb \
  xz-utils \
  zip \
  zsh \
  && echo "clean up" \
  && ln -s /usr/bin/fdfind /usr/bin/fd \
  && apt-get clean \
  && rm -rf /home/linuxbrew/.linuxbrew/share/doc \
  && rm -rf /home/linuxbrew/.linuxbrew/share/man \
  && rm -rf /usr/share/doc \
  && rm -rf /usr/share/man \
  && echo "all done!"

RUN \
  --mount=type=cache,target=/root/.cache \
  --mount=type=cache,target=/var/cache \
  --mount=type=cache,target=/var/lib/apt \
  set -ex \
  && echo "install brew" \
  && chmod 0755 /opt/extras/homebrew/install.sh \
  && /opt/extras/homebrew/install.sh \
  && echo "install brew packages" \
  && brew install \
  checkov \
  cosign \
  detect-secrets \
  dua-cli \
  exiftool \
  # firefox \
  # ffmpeg-full \
  # git-remote-codecommit \
  # golang \
  golangci-lint \
  # gradle \
  grype \
  hadolint \
  hugo \
  # imagemagick-full \
  kics \
  license-eye \
  opa \
  opentofu \
  prettier \
  stylua \
  syft \
  terraform-docs \
  terraform-linters/tap/tflint \
  tfsec \
  trivy \
  # uv \
  # webpack \
  && echo "clean up" \
  && apt-get clean \
  && brew cleanup --scrub \
  && rm -rf /home/linuxbrew/.linuxbrew/share/doc \
  && rm -rf /home/linuxbrew/.linuxbrew/share/man \
  && rm -rf /usr/share/doc \
  && rm -rf /usr/share/man \
  && echo "all done!"

RUN \
  --mount=type=cache,target=/root/.cache \
  --mount=type=cache,target=/var/cache \
  --mount=type=cache,target=/var/lib/apt \
  set -ex \
  && echo "install non-priviliged user" \
  # && useradd --create-home ubuntu \
  && mkdir -p /root/.config/opentofu \
  && mkdir -p /home/ubuntu/.config/opentofu \
  && echo 'plugin_cache_dir = "/home/ubuntu/.cache/opentofu/plugin-cache"' > /root/.config/opentofu/tofurc \
  && echo 'plugin_cache_dir = "/home/ubuntu/.cache/opentofu/plugin-cache"' > /home/ubuntu/.config/opentofu/tofurc \
  && echo 'export PATH="/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin:$PATH"' >> /root/.bashrc \
  && echo 'export PATH="/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin:$PATH"' >> /home/ubuntu/.bashrc \
  && echo 'ubuntu ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
  # && echo "brew extras" \
  # && brew install --verbose \
  # FIXME \
  && echo "install npm extras" \
  && npm install --global \
  @lhci/cli \
  browserslist \
  html-validate \
  mocha \
  npm-check-updates \
  pagefind \
  && echo "install tofu extras" \
  && tofu -chdir=/opt/extras/opentofu init \
  && tofu -chdir=/opt/extras/opentofu version \
  && echo "clean up" \
  && apt-get clean \
  && brew cleanup --scrub \
  && rm -rf /home/linuxbrew/.linuxbrew/share/doc \
  && rm -rf /home/linuxbrew/.linuxbrew/share/man \
  && rm -rf /usr/share/doc \
  && rm -rf /usr/share/man \
  && chmod 755 /home \
  && chown -R ubuntu:ubuntu /home/ubuntu \
  && find /home/ubuntu -type d -exec chmod 777 {} \; \
  && find /home/ubuntu -type f -exec chmod 666 {} \; \
  && echo "all done!"

ENV KICS_LIBRARIES_PATH=/home/linuxbrew/.linuxbrew/share/kics/assets/libraries
ENV KICS_QUERIES_PATH=/home/linuxbrew/.linuxbrew/share/kics/assets/queries

USER ubuntu
ENV HOME=/home/ubuntu
ENV XDG_CACHE_HOME="/tmp/.cache"
ENV XDG_CONFIG_HOME="/home/ubuntu/.config"
ENV XDG_DATA_HOME="/tmp/.local/share"
ENV XDG_STATE_HOME="/tmp/.local/state"
WORKDIR /home/ubuntu

