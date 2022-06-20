FROM nodered/node-red
ARG NR_ENV_ACCESS_PATH
ARG NR_USER

#-----------------------
USER root
RUN useradd --home-dir ${NR_ENV_ACCESS_PATH} --uid 1000 ${NR_USER}
RUN chown -R ${NR_USER}:root /data && chmod -R g+rwX /data
RUN chown -R ${NR_USER}:root ${NR_ENV_ACCESS_PATH} && chmod -R g+rwX ${NR_ENV_ACCESS_PATH}
# Set work directory
WORKDIR ${NR_ENV_ACCESS_PATH}
# Setup SSH known_hosts file
COPY /node-red1/data/known_hosts.sh .
RUN ./known_hosts.sh /etc/ssh/ssh_known_hosts && rm ${NR_ENV_ACCESS_PATH}/known_hosts.sh
USER ${NR_USER}

# package.json contains Node-RED NPM module and node dependencies
COPY /node-red1/package.json .
COPY /node-red1/flows.json /data


# Env variables
ENV NODE_RED_VERSION=$NODE_RED_VERSION \
    NODE_PATH=${NR_ENV_ACCESS_PATH}/node_modules:/data/node_modules \
    PATH=${NR_ENV_ACCESS_PATH}/node_modules/.bin:${PATH} \
    FLOWS=flows.json
    
# Expose the listening port of node-red
EXPOSE 1880
ENTRYPOINT ["npm", "start", "--cache", "/data/.npm", "--", "--userDir", "/data"]
