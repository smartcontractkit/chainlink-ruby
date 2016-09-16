class BlockCypherClient

  CALLBACK_URL = ENV['BLOCK_CYPHER_CALLBACK_URL']

  def self.send_transaction(data)
    new.send_transaction data
  end

  def self.subscribe_to_address(location, auth_key)
    new.subscribe_to_address location, auth_key
  end

  def self.unsubscribe_from_notifications(id)
    new.unsubscribe_from_notifications id
  end

  def get_transaction_hex(txid)
    get_transaction_info(txid).hex
  end

  def send_transaction(hex)
    client.push_hex hex
  end

  def subscribe_to_address(location, auth_key)
    callback_url = "#{CALLBACK_URL}/api/block_cypher/confirmations/#{auth_key}"

    hashie(client.event_webhook_subscribe callback_url, 'tx-confirmation', {
      address: location,
      confirmations: 10
    })
  end

  def unsubscribe_from_notifications(id)
    client.event_webhook_delete(id)
  end

  def utxos_for(address)
    response = client.address_details(address, unspent_only: true)

    response['txrefs'].map do |utxo|
      hashie({
        transaction_hash: utxo['tx_hash'],
        output_index: utxo['tx_output_n']
      })
    end
  end

  def get_transaction_info(txid)
    hashie client.blockchain_transaction(txid, includeHex: true)
  end


  private

  def client
    @client ||= BlockCypher::Api.new({
      api_token: ENV['BLOCK_CYPHER_KEY'],
      network: network,
    })
  end

  def hashie(hash)
    Hashie::Mash.new hash
  end

  def network
    if Bitcoin.network_name == :testnet3
      BlockCypher::TEST_NET_3
    else
      BlockCypher::MAIN_NET
    end
  end

end
