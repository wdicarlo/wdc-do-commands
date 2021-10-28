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

RUN git config --global http.proxy $HTTPS_PROXY \
    && git clone https://github.com/bats-core/bats-core.git /tmp/bats-core \
    && cd /tmp/bats-core \
    && ./install.sh /usr/local

RUN curl -fLo /home/dockeruser/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN git clone https://github.com/wdicarlo/wdc-do-commands.git /tmp/wdc-do-commands

RUN mkdir -p /home/dockeruser \
    && mkdir -p /home/dockeruser/projects \
    && cp -r /tmp/wdc-do-commands /home/dockeruser/wbin \
    && export PATH="$PATH:/home/dockeruser/wbin"


ENV WDC_DO_COMMANDS_DIR="/home/dockeruser/wbin"
ENV PATH="$PATH:/home/dockeruser/wbin"

COPY ./entrypoint.sh ./do_cmd_counts.csv /home/dockeruser/wbin/
COPY ./vimrc /home/dockeruser/.vimrc

RUN cd /home/dockeruser/wbin \
    && ./cmd/do-cmd-groups-slinks \
    && ./cmd/do-cmd-index -u \
    && curl -fLo /home/dockeruser/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && ./vim/do-vim-plugs -t /home/dockeruser/.vim/ -p do_vim_plugs.csv

RUN ["chmod", "+x", "/home/dockeruser/wbin/entrypoint.sh"]

ENTRYPOINT [ "/home/dockeruser/wbin/entrypoint.sh" ]

WORKDIR /home/dockeruser

CMD [ "/bin/bash" ]

