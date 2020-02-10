#!/bin/bash
# Cleanup
docker stop bpanel
docker rm bpanel
docker volume rm bpanel

# Create
docker build -t bpanel:dev .
docker volume create bpanel
docker run -d \
  --mount source=bpanel,target=/data \
  -p 5000:5000 -p 5001:5001 -p 8000:8000 \
  --env CHAIN=flo \
  --env RPC_HOST=172.16.31.54 \
  --env RPC_PASSWORD=password \
  --env NETWORK=regtest \
  --name=bpanel \
  bpanel:dev

docker logs --tail 1000 -f bpanel