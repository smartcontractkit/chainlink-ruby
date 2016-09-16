def block_cypher_fixture(id)
  text = File.read("spec/fixtures/block_cypher/#{id}.json")
  JSON.parse(text)
end

def canned_block_cypher_response(address = nil)
  address ||= Faker::Bitcoin.address
  {
    "id": "82a50145-0f29-4711-9a12-3d90795ea415",
    "url": "http://smartcontract.ngrok.io/api/block_cypher/confirmations",
    "callback_errors": 0,
    "address": address,
    "event": "tx-confirmation",
    "confirmations": 10, "filter": "event=tx-confirmation:10\u0026addr=#{address}"
  }
end

def api_tx_confirmation(auth_key, options = {})
  txid = options.fetch(:txid, SecureRandom.hex(32))
  confirmations = options.fetch(:confirmations, 0)
  btc_location = options.fetch(:btc_location, Faker::Bitcoin.address)

  {
    "block_height":-1,
     "hash": txid,
     "addresses":["1FBSEn1PaEmPackE31xxXx8wtasx5be2NW", btc_location],
     "total":4279434,
     "fees":10000,
     "size":257,
     "preference":"medium",
     "relayed_by":"5.39.6.98:8333",
     "received":"2015-10-19T21:01:11.94Z",
     "ver":1,
     "lock_time":0,
     "double_spend":false,
     "vin_sz":1,
     "vout_sz":2,
     "confirmations": confirmations,
     "inputs":[
       {
         "prev_hash":"67aef4cf84c63d87ba28eb004c1f4d4a8745d654239cc08788872a377c7a6a95",
         "output_index":1,
         "script":"47304402201d5f4ac043d3cd69fe91f0bfdf5788c14a3324963ba1fc6400b455f4afcd3fb602201711a45163a37444a7789f517fb55966b8a1f7749c7481ec7b9f2905c34b2fde014104b808685cce694ec8ad1df865546c8620420207baa0ec3a6af44f78451eb74dfd176a3932a6aaf960a0e3465b35339ec317ac8b3b87a6c3cc1f7507a24ba12d95",
         "output_value":4289434,
         "sequence":4294967295,
         "addresses":["1FBSEn1PaEmPackE31xxXx8wtasx5be2NW"],
         "script_type":"pay-to-pubkey-hash","age":3728
       }
     ],
     "outputs": [
       {
         "value":50000,
         "script":"76a914ef374a3d4526beb1befb69bdb56af8dc8583795588ac",
         "addresses": [btc_location],
         "script_type":"pay-to-pubkey-hash"
       },
       {
         "value":4229434,
         "script":"76a9149b8afce10b876dd27972d04c0cfd04cd4d073bc588ac",
         "addresses":["1FBSEn1PaEmPackE31xxXx8wtasx5be2NW"],
         "script_type":"pay-to-pubkey-hash"
       }
     ],
     "auth_key": auth_key
  }
end

def block_cypher_blockchain_transaction(txid)
  {
    "block_hash": "0000000000000000c504bdea36e531d8089d324f2d936c86e3274f97f8a44328",
    "block_height": 293000,
    "hash": txid,
    "hex": SecureRandom.hex,
    "addresses": [
      "13XXaBufpMvqRqLkyDty1AXqueZHVe6iyy",
      "19YtzZdcfs1V2ZCgyRWo8i2wLT8ND1Tu4L",
      "1BNiazBzCxJacAKo2yL83Wq1VJ18AYzNHy",
      "1GbMfYui17L5m6sAy3L3WXAtf1P32bxJXq",
      "1N2f642sbgCMbNtXFajz9XDACDFnFzdXzV"
    ],
    "total": 70320221545,
    "fees": 0,
    "size": 636,
    "preference": "low",
    "relayed_by": "",
    "confirmed": "2014-03-29T01:29:19Z",
    "received": "2014-03-29T01:29:19Z",
    "ver": 1,
    "lock_time": 0,
    "double_spend": false,
    "vin_sz": 4,
    "vout_sz": 1,
    "confirmations": 68362,
    "confidence": 1,
    "inputs": [
      {
        "prev_hash": "583910b7bf90ab802e22e5c25a89b59862b20c8c1aeb24dfb94e7a508a70f121",
        "output_index": 1,
        "script":
        "4830450220504b1ccfddf508422bdd8b0fcda2b148...",
        "output_value": 16450000,
        "sequence": 4294967295,
        "addresses": ["1GbMfYui17L5m6sAy3L3WXAtf1P32bxJXq"],
        "script_type": "pay-to-pubkey-hash"
      }
    ],
    "outputs": [
      {
        "value": 70320221545,
        "script": "76a914e6aad9d712c419ea8febf009a3f3bfdd8d222fac88ac",
        "spent_by": "35832d6c70b98b54e9a53ab2d51176eb19ad11bc4505d6bb1ea6c51a68cb92ee",
        "addresses": ["1N2f642sbgCMbNtXFajz9XDACDFnFzdXzV"],
        "script_type": "pay-to-pubkey-hash"
      }
    ]
  }
end
