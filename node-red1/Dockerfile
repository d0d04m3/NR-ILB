ARG NODE_VERSION=16
FROM nodered/node-red
ARG NR_ENV_ACCESS_PATH
ARG NR_USER

#-----------------------
RUN set -ex && \
    apt-get update && apt-get install -y \
        bash \
        tzdata \
        curl \
        nano \
        wget \
        git \
        openssl \
        openssh-client \
        ca-certificates && \
    mkdir -p /usr/src/node-red /data && \
    deluser --remove-home node && \
    # adduser --home /usr/src/node-red --disabled-password --no-create-home node-red --uid 1000 && \
    useradd --home-dir ${NR_ENV_ACCESS_PATH} --uid 1000 ${NR_USER} && \
    chown -R ${NR_USER}:root /data && chmod -R g+rwX /data && \
    chown -R ${NR_USER}:root ${NR_ENV_ACCESS_PATH} && chmod -R g+rwX ${NR_ENV_ACCESS_PATH}
# Set work directory
WORKDIR ${NR_ENV_ACCESS_PATH}
# Setup SSH known_hosts file
COPY /data/known_hosts.sh .
RUN ./known_hosts.sh /etc/ssh/ssh_known_hosts && rm ${NR_ENV_ACCESS_PATH}/known_hosts.sh

#### Stage BUILD #######################################################################################################
FROM base AS build

# Install Build tools
RUN apt-get update && apt-get install -y build-essential python && \
    npm install --unsafe-perm --no-update-notifier --no-fund --only=production && \
    npm uninstall node-red-node-gpio && \
    cp -R node_modules prod_node_modules
    
# package.json contains Node-RED NPM module and node dependencies
COPY package.json .
COPY flows.json /data


# Chown, install devtools & Clean up
RUN chown -R ${NR_USER}:root ${NR_ENV_ACCESS_PATH} && \
    apt-get update && apt-get install -y build-essential python-dev python3 && \
    rm -r /tmp/*
    
USER ${NR_USER}

# Env variables
ENV NODE_RED_VERSION=$NODE_RED_VERSION \
    NODE_PATH=${NR_ENV_ACCESS_PATH}/node_modules:/data/node_modules \
    PATH=/usr/src/node-red/node_modules/.bin:${PATH} \
    FLOWS=flows.json
    
# Expose the listening port of node-red
EXPOSE 1880
ENTRYPOINT ["npm", "start", "--cache", "/data/.npm", "--", "--userDir", "/data"]
