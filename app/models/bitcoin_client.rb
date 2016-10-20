class BitcoinClient

  include BinaryAndHex

  SATOSHIS_PER_BTC = 100_000_000.to_f
  CONFIRMATION_MINIMUM = ENV['BITCOIN_CONFIRMATION_MINIMUM'].to_i

  def get_transaction(txid)
    tx_hex = client.get_transaction_hex txid
    Bitcoin::Protocol::Tx.new hex_to_bin(tx_hex)
  end

  def unsubscribe_from_address(address)
    BlockCypherClient.delay.unsubscribe_from_notifications address.bcy_id
  end

  def public_keys_for_tx(hex)
    tx = parsed_tx hex
    p2sh = parsed_script tx.inputs.first.script_sig
    multisig = parsed_script p2sh.chunks.last

    multisig.get_multisig_pubkeys.map do |public_key|
      bin_to_hex public_key unless (public_key.blank? || public_key == 0)
    end.compact
  end

  def signatures_for(hex, key_pair)
    tx = parsed_tx hex

    tx.inputs.map.with_index do |input, index|
      SignatureBuilder.new(index: index, tx: tx, sign_with: key_pair).perform
    end
  end

  def add_signatures(options)
    MultisigTxSigAdder.new tx_object_for(options, :tx)
  end

  def get_transaction_info(txid)
    Hashie::Mash.new(client.get_transaction_info txid)
  end


  private

  def client
    bcy
  end

  def bcy
    @bcy ||= BlockCypherClient.new
  end

  def tx_object_for(options, key)
    tx = options[key]
    return options unless tx.is_a? String

    options[key] = parsed_tx(tx)
    options
  end

  def parsed_tx(hex)
    Bitcoin::Protocol::Tx.new hex_to_bin(hex)
  end

  def parsed_script(binary)
    Bitcoin::Script.new binary
  end

end
