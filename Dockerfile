# Copyright (c) cjadeveloper 2019

# Based on jupyter/base-notebook
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# https://hub.docker.com/r/jupyter/base-notebook/dockerfile

# Ubuntu 18.04 (bionic) from 2019-10-29
# https://github.com/tianon/docker-brew-ubuntu-core/blob/dist-amd64/bionic/Dockerfile
ARG BASE_CONTAINER=ubuntu:bionic-20191029
FROM ${BASE_CONTAINER}

LABEL maintainer="Cristian Javier Azulay <cjadeveloper@gmail.com>"
ARG NB_USER="johndoe"
ARG NB_UID="1000"
ARG NB_GID="100"

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
  && apt-get install -yq --no-install-recommends \
    apt-utils \
    curl \
    gnupg \
    gnupg2 \
    gnupg1 \
    apt-transport-https \ 
    debconf-utils \
    gcc \
    build-essential \
    g++-5 \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    run-one \
  && rm -rf /var/lib/apt/lists/*

# adding custom MS repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install SQL Server drivers
RUN apt-get update \
&& ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev

# install SQL Server tools
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

#RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
RUN echo "es_AR.UTF-8 UTF-8" > /etc/locale.gen \
&& locale-gen

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=es_AR.UTF-8 \
    LANG=es_AR.UTF-8 \
    LANGUAGE=es_AR:es
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# Add a script that we will use to correct permissions after running certain commands
ADD fix-permissions.sh /usr/local/bin/fix-permissions.sh

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER with name 'johndoe' with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su \
&& sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers \
&& sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers \
&& useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
&& mkdir -p $CONDA_DIR \
&& chown $NB_USER:$NB_GID $CONDA_DIR \
&& chmod g+w /etc/passwd

RUN fix-permissions.sh $HOME \
&& fix-permissions.sh "$(dirname $CONDA_DIR)"

USER $NB_UID
WORKDIR $HOME

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work \
&& fix-permissions.sh /home/$NB_USER
