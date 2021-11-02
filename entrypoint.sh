#!/usr/bin/env bash

set -e

runuser="0"

if [[ "${CUR_UID:-"0"}" != '0' ]]; then
  addgroup --gid ${CUR_GID} dockeruser > /dev/null || groupmod -n dockeruser $(getent group ${CUR_GID} | cut -d: -f1)
  useradd -g dockeruser --uid ${CUR_UID} dockeruser > /dev/null
  addgroup dockeruser dockeruser > /dev/null
  addgroup dockeruser sudo > /dev/null
  #addgroup dockeruser docker > /dev/null

  remote_docker_group_id="$(stat -c '%g' /var/run/docker.sock)"
  remote_docker_group_name="$(getent group $remote_docker_group_id | cut -d: -f1)"

  if test -z "$remote_docker_group_name"; then
    remote_docker_group_name="rdocker"
    groupadd --gid "$remote_docker_group_id" "$remote_docker_group_name"
  fi

  addgroup dockeruser "$remote_docker_group_name" > /dev/null

  echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
  export HOME=/home/dockeruser
  echo "source \$WDC_DO_COMMANDS_DIR/bin/do_bash_customization" > /home/dockeruser/.bashrc
  echo "export PATH=\"\$PATH:/home/dockeruser/mbin\"" >> /home/dockeruser/.bashrc

  chown -R dockeruser:dockeruser /home/dockeruser/ 

  runuser="dockeruser"
fi

exec gosu "$runuser" "$@"
