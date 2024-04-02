# syntax=docker/dockerfile:1.6

ARG VERSION=20.04

FROM ubuntu:${VERSION}

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        openssh-client \
        ssh \
        sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG USER_NAME=vagrant
ARG USER_GROUP=${USER_NAME}
ARG GITHUB_USER=${GITHUB_USER:-pythoninthegrass}

RUN <<EOF
#!/usr/bin/env bash
set -euxo pipefail
useradd --create-home -s /bin/bash ${USER_NAME}
echo -n ${USER_NAME}:${USER_GROUP} | chpasswd
echo "${USER_NAME} ALL = NOPASSWD: ALL" > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant
USER_HOME=$(getent passwd ${USER_NAME} | cut -d: -f6)
mkdir -p ${USER_HOME}/.ssh
chmod 700 ${USER_HOME}/.ssh
USER_KEY=$(curl -s https://github.com/${GITHUB_USER}.keys)
echo "$USER_KEY" > ${USER_HOME}/.ssh/authorized_keys
chmod 600 ${USER_HOME}/.ssh/authorized_keys
chown -R ${USER_NAME}:${USER_GROUP} ${USER_HOME}/.ssh
sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers
sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config
mkdir /var/run/sshd
EOF

USER ${USER_NAME}

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
