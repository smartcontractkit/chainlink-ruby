module SpecHelpers
  def chain_subscribe_hash(options = {})
    id = options[:id] || SecureRandom.uuid
    address = options[:address] || Faker::Bitcoin.address
    {
      "id": id,
      "state": "enabled",
      "url": "http://nayru.ngrok.io/api/chain/transactions",
      "type": "address",
      "block_chain": "bitcoin",
      "address": address
    }
  end

  def chain_params(options = {})
    confirmations = options[:confirmations] || 2
    input_addresses = options[:input_addresses] || [Faker::Bitcoin.address]
    output_addresses = options[:output_addresses] || [Faker::Bitcoin.address]
    txid = options[:txid] || SecureRandom.hex(32)
    address = options[:address] || output_addresses.first
    auth_key = options[:auth_key] || SecureRandom.uuid
    notification_id = options[:notifcation_id] || SecureRandom.uuid

    {
      "id": "",
      "sequence": 0,
      "created_at": "2015-03-13T00:26:51.39687Z",
      "delivery_attempt": 1,
      "notification_id": notification_id,
      "payload": {
        "type": "address",
        "block_chain": "bitcoin",
        "address": address,
        "sent": 0,
        "received": 0,
        "input_addresses": input_addresses,
        "output_addresses": output_addresses,
        "transaction_hash": txid,
        "block_hash": "00000000000000001f268be92305a4ad575f92a740413bf96fa4dbe25f808c70",
        "confirmations": confirmations
      },
      auth_key: auth_key,
    }
  end

  def chain_tx_info(options = {})
    inputs = (options[:inputs] || [Faker::Bitcoin.address]).map do |address|
      chain_input_info(addresses: [address])
    end
    outputs = (options[:outputs] || [Faker::Bitcoin.address]).map do |address|
      chain_output_info(addresses: [address])
    end

    {
      "hash": "915cc74878be4aff0d83af6c20eec7c8b3cbbb507638e890084a0f4b8ea9984a",
      "block_hash": "000000000000000006fa6123a3e9afca657fc860319089c4d690ba0329ff9d97",
      "block_height": 382023,
      "block_time": "2015-11-04T14:55:01Z",
      "chain_received_at": "2015-11-04T14:30:42.623Z",
      "confirmations": 191,
      "lock_time": 0,
      "inputs": inputs,
      "outputs": outputs,
      "fees": 10000,
      "amount": 1060000
    }
  end

  def chain_input_info(options)
    addresses = Array.wrap(options[:addresses] || Faker::Bitcion.address)

    {
      "transaction_hash": SecureRandom.hex,
      "output_hash": SecureRandom.hex,
      "output_index": 1,
      "value": 1030000,
      "addresses": addresses,
      "script_signature": SecureRandom.hex,
      "script_signature_hex": SecureRandom.hex,
      "sequence": 4294967295
    }
  end

  def chain_output_info(options)
    addresses = Array.wrap(options[:addresses] || Faker::Bitcion.address)

    {
      "transaction_hash": SecureRandom.hex,
      "output_index": 1,
      "value": 1000000,
      "addresses": addresses,
      "script": "OP_DUP OP_HASH160 9b8afce10b876dd27972d04c0cfd04cd4d073bc5 OP_EQUALVERIFY OP_CHECKSIG",
      "script_hex": SecureRandom.hex,
      "script_type": SecureRandom.hex,
      "required_signatures": 1,
      "spent": false,
      "spending_transaction": nil
    }
  end
end
