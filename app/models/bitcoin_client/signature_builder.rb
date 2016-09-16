class BitcoinClient
  class SignatureBuilder

    include BinaryAndHex

    def initialize(options)
      @tx = options[:tx]
      @input_index = options[:index] || 0
      @key_pair = options[:sign_with]
    end

    def perform
      signature = Bitcoin.sign_data(key_pair.bitcoin_key, sig_hash)
      bin_to_hex signature
    end


    private

    attr_reader :input_index, :key_pair, :tx

    def input
      tx.inputs[input_index]
    end

    def sig_hash
      redeem_script = Bitcoin::Script.new(input.script_sig).chunks.last
      tx.signature_hash_for_input(input_index, redeem_script)
    end

  end
end

