FROM bitnami/minideb:bullseye

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      git \
      file \
      ca-certificates \
      apt-transport-https \
      gnupg \
      openssh-client \
      sudo \
      gosu \
      bsdmainutils \
      ncurses-bin \
      vim \
      curl \
      jq \
      bash-completion \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/dockeruser \
    && mkdir -p /home/dockeruser/mbin \
    && mkdir -p /home/dockeruser/projects \
    && export PATH="$PATH:/home/dockeruser/wbin/bin:/home/dockeruser/mbin"


ENV WDC_DO_COMMANDS_DIR="/home/dockeruser/wbin"
ENV WDC_DO_COMMANDS_BIN="/home/dockeruser/wbin/bin"
ENV PATH="$PATH:/home/dockeruser/wbin/bin:/home/dockeruser/mbin"

COPY ./.cache/wbin /home/dockeruser/wbin
COPY ./.cache/bin/. /home/dockeruser/wbin/
COPY ./entrypoint.sh /home/dockeruser/wbin/
COPY ./bin/do_cmd_counts.csv /home/dockeruser/wbin/bin/

RUN cd /home/dockeruser/wbin \
    && ./cmd/do-cmd-groups-slinks \
    && ./cmd/do-cmd-index -u 
    #&& [ -f ./bin/nvim ] && rm -f ./bin/nvim

COPY ./.cache/vim/plugged/. /home/dockeruser/.vim/plugged/
COPY ./.cache/vim/autoload/. /home/dockeruser/.vim/autoload/
COPY ./.cache/neovim/squashfs-root/usr/. /usr/local/
COPY ./vimrc /home/dockeruser/.vimrc

COPY ./.cache/bats-core /tmp/bats-core
RUN [ -f /tmp/bats-core/install.sh ] && /tmp/bats-core/install.sh /usr/local || true

RUN ["chmod", "+x", "/home/dockeruser/wbin/entrypoint.sh"]

ENTRYPOINT [ "/home/dockeruser/wbin/entrypoint.sh" ]

WORKDIR /home/dockeruser

CMD [ "/bin/bash" ]

