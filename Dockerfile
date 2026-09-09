FROM docker.io/vastai/kvm:ubuntu_desktop_22.04-2025-11-21

ENV DEBIAN_FRONTEND=noninteractive

# 32-бит архитектура и автопринятие лицензии Steam (без этого apt зависает на EULA)
RUN dpkg --add-architecture i386 && \
    echo "steam steam/question select I AGREE" | debconf-set-selections && \
    echo "steam steam/license note ''" | debconf-set-selections

RUN apt-get update && \
    apt-get install -y software-properties-common curl gnupg jq python3 debconf-utils rclone && \
    add-apt-repository -y ppa:kubuntu-ppa/backports && \
    add-apt-repository -y multiverse && \
    mkdir -p /etc/apt/keyrings /usr/share/keyrings && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list && \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg -o /usr/share/keyrings/tailscale-archive-keyring.gpg && \
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list -o /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && \
    apt-get install -y \
        wget ca-certificates ffmpeg libcap2-bin \
        gamemode nvtop btop vulkan-tools libvulkan1 mesa-utils \
        x11-xserver-utils xinput pulseaudio-utils inotify-tools \
        steam-installer wine tailscale \
        flatpak plasma-discover plasma-discover-backend-flatpak \
        xdg-desktop-portal xdg-desktop-portal-kde xdg-utils \
        desktop-file-utils google-chrome-stable && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Sunshine — качаем нужный релиз через python (jq в контейнере глючил на парсинге)
RUN cat << 'PYEOF' > /tmp/get_sunshine.py
import urllib.request, json
req = urllib.request.Request("https://api.github.com/repos/LizardByte/Sunshine/releases/latest", headers={"User-Agent": "curl"})
data = json.loads(urllib.request.urlopen(req).read().decode())
assets = data.get("assets", [])
url = None
for a in assets:
    n = a["name"].lower()
    if ("22.04" in n or "jammy" in n) and n.endswith(".deb"):
        url = a["browser_download_url"]; break
if not url:
    for a in assets:
        if a["name"].endswith(".deb"):
            url = a["browser_download_url"]; break
urllib.request.urlretrieve(url, "/tmp/sunshine.deb")
PYEOF
RUN python3 /tmp/get_sunshine.py && \
    apt-get update && \
    (apt-get install -y /tmp/sunshine.deb || apt-get install -f -y) && \
    rm -f /tmp/get_sunshine.py /tmp/sunshine.deb

EXPOSE 47984 47989 47990 47998 47999 48000 48001 48002 48010
