#FROM public-dockerhub-remote.artifactory-espoo1.int.net.nokia.com/bitnami/minideb:stretch-amd64
FROM bitnami/minideb:stretch-amd64

RUN apt-get update && apt-get install -y \
    git \
    file \
    sudo \
    gosu \
    bsdmainutils \
    ncurses-bin \
    vim \
    curl \
    jq

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

