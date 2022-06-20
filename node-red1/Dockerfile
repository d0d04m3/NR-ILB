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

#### Stage RELEASE #####################################################################################################
FROM base AS RELEASE
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_REF
ARG NODE_RED_VERSION
ARG ARCH
ARG TAG_SUFFIX=default

LABEL org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.dockerfile=".docker/Dockerfile.debian" \
    org.label-schema.license="Apache-2.0" \
    org.label-schema.name="Node-RED" \
    org.label-schema.version=${BUILD_VERSION} \
    org.label-schema.description="Low-code programming for event-driven applications." \
    org.label-schema.url="https://nodered.org" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/node-red/node-red-docker" \
    org.label-schema.arch=${ARCH} \
    authors="Dave Conway-Jones, Nick O'Leary, James Thomas, Raymond Mouthaan"

COPY --from=build ${NR_ENV_ACCESS_PATH}/prod_node_modules ./node_modules

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
