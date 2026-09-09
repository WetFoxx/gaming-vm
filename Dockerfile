FROM nvidia/cuda:12.1.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb curl wget git rsync openssh-server sudo tmux locales software-properties-common rclone \
    libglib2.0-0 libssl3 libopus0 libasound2 libayatana-appindicator3-1 libgbm1 \
    libxcb-randr0 libxcb-shape0 libxcb-xfixes0 libxcb-xtest0 libxtst6 fluxbox \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null \
    && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list \
    && apt-get update && apt-get install -y tailscale \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/LizardByte/Sunshine/releases/download/v0.23.1/sunshine-ubuntu-22.04-amd64.deb \
    && apt-get update && apt-get install -y ./sunshine-ubuntu-22.04-amd64.deb \
    && rm sunshine-ubuntu-22.04-amd64.deb \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

EXPOSE 47984 47989 47990 47998 47999 48000 48001 48002 48010
