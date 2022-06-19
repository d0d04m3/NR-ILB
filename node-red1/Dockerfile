ARG NODE_VERSION=16
FROM nodered/node-red



# Copy package.json to the WORKDIR so npm builds all
# of your added nodes modules for Node-RED
#COPY /data/package.json .
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production

# Copy _your_ Node-RED project files into place
# NOTE: This will only work if you DO NOT later mount /data as an external volume.
#       If you need to use an external volume for persistence then
#       copy your settings and flows files to that volume instead.
COPY /data/settings.js /home/94r4d0x/.node-red/settings.js
#COPY /data/flows_cred.json /home/94r4d0x/.node-red/flows_cred.json
#COPY /data/flows.json /home/94r4d0x/.node-red/flows.json

# You should add extra nodes via your package.json file but you can also add them here:
#WORKDIR /usr/src/node-red
ENTRYPOINT npm start --  --userDir /home/94r4d0x/.node-red
#RUN npm install node-red-node-smooth

USER root
RUN chown -R node-red:root /data && chmod -R g+rwX /data && \
    chown -R node-red:root /usr/src/node-red && chmod -R g+rwX /usr/src/node-red
    
# Set work directory
WORKDIR /usr/src/node-red

# Setup SSH known_hosts file
COPY /data/known_hosts.sh .
RUN ["chmod", "+x", "./known_hosts.sh"]
RUN ./known_hosts.sh /etc/ssh/ssh_known_hosts && rm /usr/src/node-red/known_hosts.sh
