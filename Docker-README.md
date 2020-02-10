# Docker bPanel
 
> Run the bPanel Dashboard software! (https://github.com/mediciland/bpanel)
 
[![Image Pulls](https://img.shields.io/docker/pulls/mediciland/bpanel.svg)](https://hub.docker.com/r/mediciland/bpanel) [![Image Stars](https://img.shields.io/docker/stars/mediciland/bpanel.svg)](https://hub.docker.com/r/mediciland/bpanel)
 
This image runs the official FLO Core full node and optionally exposes an RPC connection.
 
## Available Versions
 
You can see all images available to pull from Docker Hub via the [Tags page](https://hub.docker.com/r/mediciland/bpanel/tags/).
 
## Usage Example
Startup an instance of [mediciland/fcoin](https://hub.docker.com/r/mediciland/fcoin) to connect to, then run the following commands.
 
```
docker run -d \
  -p 5000:5000 -p 5001:5001 -p 8000:8000 \
  --env CHAIN=flo \
  --env RPC_HOST=YOUR_LOCAL_IP \
  --env RPC_PASSWORD=password \
  --env NETWORK=testnet \
  --name=bpanel \
  mediciland/bpanel

docker logs -f bpanel
```
 
## Environment Variables
 
FLO Core uses Environment Variables to allow for configuration settings. You set the Env Variables in your `docker run` startup command. Here are the config settings offered by this image.

* **`CHAIN`**: [`flo`|`bitcoin`|`bitcoincash`|`handshake`] The Chain you wish to run on (Default `flo`). 
* **`NETWORK`**: [`main`|`testnet`|`regtest`] The Chain network you wish to run on (Default `main`).
* **`RPC_HOST`**: [`String`] The Hostname/IP address of the RPC node to use as your data source
* **`RPC_PASSWORD`**: [`String`] The RPC password for the RPC Host you are connecting to
* **`BPANEL_PLUGINS`**: [`String`] A list of plugins that you wish to install, seperated by commas (Default `bpanel-whitelist,@bpanel/bpanel-footer,@bpanel/bmenace-theme,@mediciland/bpanel-homepage,@mediciland/bpanel-recent-blocks-widget,@mediciland/bpanel-transaction-detail`)
* **`BPANEL_ENDPOINT_WHITELIST`**: [`Array<String|Object>`] An array of strings/objects containing API endpoints that are whitelisted and available to hit (Default is contents of `ci/config/default-whitelist.js`)
* **`CUSTOM_BPANEL_CONFIG`**: [`String`] A string (seperated with `\n` to split lines lines) of extra config variables to add to `~/.bpanel/config.js`
 
## Security Reports
 
Please email [security@mediciventures.com](mailto:security@mediciventures.com) with security concerns.
 
## Maintainers
 
[![MediciLand](https://www.mediciland.com/images/mlg-logo-color.png)](https://mediciland.com)