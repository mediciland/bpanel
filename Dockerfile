# FROM node:alpine AS base
FROM mhart/alpine-node:latest AS base

# temporarily use this fork of node:alpine
# because it has a newer version of npm
# temporarily update npm manually
# because of bug introduced in npm 6.0.0

RUN mkdir -p /bpanel/src/app/dist
RUN mkdir -p /data/clients

WORKDIR /bpanel/src/app

ENTRYPOINT [ "node" ]
CMD [ "server" ]

ARG NPM_VERSION=6.3.0

# Install updates
RUN apk upgrade --no-cache && \
    apk add --no-cache git python make g++ bash && \
    npm install -g npm@$NPM_VERSION

# install dependencies for node-hid
RUN apk add --no-cache linux-headers eudev-dev libusb-dev
# install handshake deps
RUN apk add --no-cache unbound-dev

COPY package.json \
     package-lock.json \
     /bpanel/src/app/

# Install dependencies
FROM base AS build

# dont run preinstall scripts here
# by omitting --unsafe-perm
RUN npm install

# this is a grandchild dependency of hsd that gets skipped for some reason
# and needs to be installed manually
RUN npm install budp

# Bundle app
FROM base
EXPOSE 80 443 5000 5001 8000
EXPOSE 8000/udp
COPY --from=build /bpanel/src/app/node_modules /bpanel/src/app/node_modules
COPY pkg.js /bpanel/src/app/pkg.js
COPY vendor /bpanel/src/app/vendor
COPY scripts /bpanel/src/app/scripts
COPY configs /bpanel/src/app/configs
COPY server /bpanel/src/app/server
COPY webapp /bpanel/src/app/webapp
COPY ci/config/start.sh /bpanel/start.sh
RUN mkdir -p /bpanel/clients
COPY ci/config/base-client.conf /bpanel/clients/base-client.conf
COPY ci/config/default-whitelist.js /bpanel/default-whitelist.js
RUN chmod +x /bpanel/start.sh
ENTRYPOINT [ "bash" ]
CMD [ "/bpanel/start.sh" ]
