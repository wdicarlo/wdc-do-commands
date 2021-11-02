FROM bitnami/minideb:bullseye

RUN echo "Acquire::http::Proxy \"false\";" > /etc/apt/apt.conf \
    && echo "Acquire::https::Proxy \"false\";" >> /etc/apt/apt.conf \
    && apt-get update \
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

RUN NO_PROXY="$NO_PROXY,.github.com" git clone https://github.com/bats-core/bats-core.git /tmp/bats-core \
    && cd /tmp/bats-core \
    && ./install.sh /usr/local

RUN NO_PROXY="$NO_PROXY,.githubusercontent.com" curl -fLo /home/dockeruser/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN NO_PROXY="$NO_PROXY,.github.com" git clone --single-branch --branch dev_bin_folder https://github.com/wdicarlo/wdc-do-commands.git /tmp/wdc-do-commands

RUN mkdir -p /home/dockeruser \
    && mkdir -p /home/dockeruser/projects \
    && cp -r /tmp/wdc-do-commands /home/dockeruser/wbin \
    && export PATH="$PATH:/home/dockeruser/wbin/bin"


ENV WDC_DO_COMMANDS_DIR="/home/dockeruser/wbin"
ENV WDC_DO_COMMANDS_BIN="/home/dockeruser/wbin/bin"
ENV PATH="$PATH:/home/dockeruser/wbin/bin"

COPY ./entrypoint.sh /home/dockeruser/wbin/
COPY ./bin/do_cmd_counts.csv /home/dockeruser/wbin/bin/
COPY ./vimrc /home/dockeruser/.vimrc

RUN cd /home/dockeruser/wbin \
    && ./cmd/do-cmd-groups-slinks \
    && ./cmd/do-cmd-index -u \
    && NO_PROXY="$NO_PROXY,.githubusercontent.com" curl -fLo /home/dockeruser/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && NO_PROXY="$NO_PROXY,.github.com" ./vim/do-vim-plugs -t /home/dockeruser/.vim/ -p ./bin/do_vim_plugs.csv

RUN ["chmod", "+x", "/home/dockeruser/wbin/entrypoint.sh"]

ENTRYPOINT [ "/home/dockeruser/wbin/entrypoint.sh" ]

WORKDIR /home/dockeruser

CMD [ "/bin/bash" ]

