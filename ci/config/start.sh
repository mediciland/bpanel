#!/bin/bash

mkdir -p /root/.bpanel/clients
cp /bpanel/clients/base-client.conf /root/.bpanel/clients/base-client.conf
# Use Env variables in Config
## Change Network Config if needed
echo "Setup configs..."
if [ "$NETWORK" == "testnet" ]
then
  sed -i 's/main/testnet/g' /root/.bpanel/clients/base-client.conf
fi
if [ "$NETWORK" == "regtest" ]
then
  sed -i 's/main/regtest/g' /root/.bpanel/clients/base-client.conf
fi
### Defaults for chain
if [ -z "$CHAIN" ]
then
  echo "WARNING! No CHAIN was set, defaulting to 'flo'"
  CHAIN=flo
fi

if [ -z "$BPANEL_PLUGINS" ]
then
  export BPANEL_PLUGINS=bpanel-whitelist,@bpanel/bpanel-footer,@bpanel/bmenace-theme,@mediciland/bpanel-homepage,@mediciland/bpanel-recent-blocks-widget,@mediciland/bpanel-transaction-detail
  echo "WARNING! BPANEL_PLUGINS was NOT set, defaulting to plugins to run an Explorer: $BPANEL_PLUGINS"
fi

if [ -z "$BPANEL_ENDPOINT_WHITELIST" ]
then
  BPANEL_ENDPOINT_WHITELIST=$(cat /bpanel/default-whitelist.js)
  echo "WARNING! BPANEL_ENDPOINT_WHITELIST was NOT set, defaulting to: $BPANEL_ENDPOINT_WHITELIST"
fi

### Swap in chain
sed -i "s/CHAIN/$CHAIN/g" /root/.bpanel/clients/base-client.conf
### Add RPC_HOST, RPC_PORT, and RPC_PASSWORD to the config
if [ -z "$RPC_HOST" ]
then
  echo "You must set an RPC_HOST in order to add a network to bPanel!"
  exit -1
else 
  sed -i "s/RPC_HOST/$RPC_HOST/g" /root/.bpanel/clients/base-client.conf
fi

if [ ! -z "$RPC_PORT" ]
then
  echo "port: $RPC_PORT" >> /root/.bpanel/clients/base-client.conf
fi

if [ -z "$RPC_PASSWORD" ]
then
  echo "You must set an RPC_PASSWORD in order to add a network to bPanel!"
  exit -1
else 
  sed -i "s/RPC_PASSWORD/$RPC_PASSWORD/g" /root/.bpanel/clients/base-client.conf
fi

## Create default config, set whitelist, and custom config options
# echo "module.exports = { plugins: [], localPlugins: [],  }" > /root/.bpanel/config.js

# Pregenerate configs
cd /bpanel/src/app
npm install --unsafe-perm

## Add whitelist and custom config to the default generated config.js file
### Remove the last line of config.js
sed -i '$ s/.$//' /root/.bpanel/config.js
### Write whitelist and custom config
echo "whitelist: $BPANEL_ENDPOINT_WHITELIST, $CUSTOM_BPANEL_CONFIG }" >> /root/.bpanel/config.js

cat /root/.bpanel/config.js

# Install plugins
echo "Preinstall plugins"
node /bpanel/src/app/server/build-plugins.js

# Initial Startup of bPanel
echo -e "\n\nStarting bPanel for $CHAIN $NETWORK"
node --max_old_space_size=4096 /bpanel/src/app/server --dev --watch-poll