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
## Add any custom config values
if [ ! -z "$CUSTOM_BPANEL_CONFIG" ]
then
  echo -e "${CUSTOM_CLIENT_CONFIG}" >> /root/.bpanel/clients/base-client.conf
fi


# Initial Startup of bPanel
echo "Starting bPanel for $CHAIN $NETWORK"
cd /bpanel/src/app
npm install --unsafe-perm
node --max_old_space_size=4096 /bpanel/src/app/server --dev --watch-poll --clear