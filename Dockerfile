FROM node:8-stretch
MAINTAINER Kitware, Inc. <kitware@kitware.com>

EXPOSE 8080

# checkout girder 2.x
RUN git clone https://github.com/girder/girder.git  --branch 2.x-maintenance /girder


RUN apt-get update && apt-get install -qy \
    gcc \
    libpython2.7-dev \
    git \
    libldap2-dev \
    libsasl2-dev && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

# go to the plugins directory
WORKDIR /girder/plugins

# remove unneeded and sometimes troublesome plugins
RUN rm -r ldap
RUN rm -r oauth

# add modsquad backend
RUN git clone https://github.com/d3m-purdue/modsquad-girder25-plugin.git


# build girder with modsquad
WORKDIR /girder
RUN pip install --upgrade pyopenssl
RUN pip install --upgrade --upgrade-strategy eager --editable .[plugins]
RUN girder-install web --all-plugins

ENTRYPOINT ["girder", "serve"]
