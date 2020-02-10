[
  // https://bcoin.io/api-docs/#bcoin-node
  // GET /                      Get basic info
  // GET /tx/:hash              TX by hash
  // GET /tx/address/:address   TX by address
  // GET /coin/:hash/:index     UTXO by txid and index
  // GET /block/:block          Block by hash or height
  // GET /header/:block         Block header by hash or height
  // GET /filter/:block         BIP158 block filter by hash or height
  // GET /mempool               Mempool snapshot
  // GET /fee                   Estimate fee
  {
    method: 'GET', 
    path: 'node',
  },
  // https://bcoin.io/api-docs/#broadcast-transaction
  // POST /broadcast            Broadcast a Transaction
  {
    method: 'POST',
    path: 'node/broadcast'
  },
  // https://bcoin.io/api-docs/#rpc-calls-node
  // ALLOW the following RPC Calls:
  // getpeerinfo
  // getblockchaininfo
  // getblock
  // getblockcount
  // getblockbyheight
  // getblockhash
  // getblockheader
  // getdifficulty
  // getnetworkhashps
  {
    method: 'POST',
    path: 'node',
    body: {
      method: /getpeer\w+|(getblock)\w+|getblock|getdifficulty|getnetworkhashps/,
    },
  },
]