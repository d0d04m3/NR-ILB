FROM nodered/node-red
FROM python:3.9.1-slim-buster AS development_build

ARG NR_ENV_ACCESS_PATH
ARG NR_USER

ARG DJANGO_ENV

ENV DJANGO_ENV=${DJANGO_ENV} \
  # python:
  PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  # pip:
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  # poetry:
  POETRY_VERSION=1.1.4 \
  POETRY_VIRTUALENVS_CREATE=false \
  POETRY_CACHE_DIR='/var/cache/pypoetry'

# System deps:
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    bash \
    build-essential \
    curl \
    gettext \
    git \
    libpq-dev \
    wget \
    openssh-client \
  # Cleaning cache:
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  && pip install "poetry==$POETRY_VERSION" && poetry --version

#-----------------------
USER root
RUN mkdir -p ${NR_ENV_ACCESS_PATH} /data 
#RUN touch /etc/ssh/ssh_known_hosts
RUN useradd --home-dir ${NR_ENV_ACCESS_PATH} --uid 1000 ${NR_USER}
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
#COPY /node-red1/package.json .
COPY /node-red1/flows.json /data
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production


# Env variables
ENV NODE_RED_VERSION=$NODE_RED_VERSION \
    NODE_PATH=${NR_ENV_ACCESS_PATH}/node_modules:/data/node_modules \
    PATH=${NR_ENV_ACCESS_PATH}/node_modules/.bin:${PATH} \
    FLOWS=flows.json
    
# Expose the listening port of node-red
EXPOSE 1880
"ENTRYPOINT ["npm", "start", "--cache", "/data/.npm", "--", "--userDir", "/data"]
ENTRYPOINT npm start --  --userDir ${NR_ENV_ACCESS_PATH}
