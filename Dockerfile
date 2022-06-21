FROM alpine:latest

ARG NR_ENV_ACCESS_PATH
ARG NR_USER
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache build-base python3 py3-pip && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
# System deps:
RUN set -ex && \
    apk add --no-cache \
        bash \
        tzdata \
        iputils \
        curl \
        nano \
        git \
        openssl \
        openssh-client \
        ca-certificates \
        sudo \
        nodejs \
        npm \
        net-tools \
        iputils \
        
  

#-----------------------
USER root
RUN mkdir -p ${NR_ENV_ACCESS_PATH} /data 
#RUN touch /etc/ssh/ssh_known_hosts
RUN adduser -h ${NR_ENV_ACCESS_PATH} -D -H ${NR_USER} -u 1000 
#RUN useradd --home-dir ${NR_ENV_ACCESS_PATH} --uid 1000 ${NR_USER}
RUN chown -R ${NR_USER}:root /data && chmod -R g+rwX /data
RUN chown -R ${NR_USER}:root ${NR_ENV_ACCESS_PATH} && chmod -R g+rwX ${NR_ENV_ACCESS_PATH}

# Set work directory
WORKDIR ${NR_ENV_ACCESS_PATH}
# Setup SSH known_hosts file
COPY /node-red1/data/known_hosts.sh .
RUN ["chmod", "+x", "./known_hosts.sh"]
RUN ./known_hosts.sh /etc/ssh/ssh_known_hosts && rm ${NR_ENV_ACCESS_PATH}/known_hosts.sh

USER ${NR_USER}
# package.json contains Node-RED NPM module and node dependencies
COPY /node-red1/package.json .
COPY /node-red1/flows.json /data
#ARG NR_ENV_ACCESS_PATH
#ARG NR_USER
#RUN node -v
#RUN sudo npm install -g --unsafe-perm node-red
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production 
#RUN npm audit fix --force
COPY /node-red1/data/settings.js ${NR_ENV_ACCESS_PATH}/.node-red/settings.js
# Env variables
ENV NODE_RED_VERSION=$NODE_RED_VERSION \
    NODE_PATH=${NR_ENV_ACCESS_PATH}/node_modules:/data/node_modules \
    PATH=${NR_ENV_ACCESS_PATH}/node_modules/.bin:${PATH} \
    FLOWS=flows.json
    
# Expose the listening port of node-red
#EXPOSE 1880
#ENTRYPOINT ["npm", "start", "--cache", "/data/.npm", "--", "--userDir", "/data"]
ENTRYPOINT npm start --  --userDir ${NR_ENV_ACCESS_PATH}
