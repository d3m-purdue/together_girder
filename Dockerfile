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

# go to the configuration directory and change the defaults so it will work with a nearby mongo 
# docker instance
WORKDIR /girder/girder/conf
RUN sed -i -r "s/127.0.0.1/0.0.0.0/" girder.dist.cfg
RUN sed -i -r "s/localhost:27017/172.17.0.2:27017/" girder.dist.cfg

# go to the plugins directory
WORKDIR /girder/plugins

# remove unneeded and sometimes troublesome plugins
RUN rm -r ldap
RUN rm -r oauth

# add modsquad backend
RUN git clone https://github.com/d3m-purdue/modsquad-girder25-plugin.git

WORKDIR /girder
# pyopenssl line needed to keep girder build from failing
RUN pip install --upgrade pyopenssl

# build girder with modsquad
RUN pip install --upgrade --upgrade-strategy eager --editable .[plugins]
RUN girder-install web --all-plugins

ENTRYPOINT ["girder", "serve"]


