FROM archlinux:base

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm --needed --overwrite '*' \
  sudo sed pacman-contrib

COPY entrypoint.sh /entrypoint.sh
COPY update.sh /update.sh

RUN chmod +x /entrypoint.sh
RUN chmod +x /update.sh

ENTRYPOINT ["/entrypoint.sh"]