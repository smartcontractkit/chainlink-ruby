class BitcoinClient
  class MultisigTxSigAdder < BitcoinBuilder

    include BinaryAndHex

    def initialize(options)
      @tx = options[:tx]
      @signatures = options[:signatures].map{ |sig| hex_to_bin(sig) }
      super
    end

    def perform
      signatures.each.with_index do |signature, index|
        input = tx.inputs[index]
        sig_hash = sig_hash_for(input, index)
        script_sig = script_sig_plus_sig(input.script_sig, signature)
        sorted = Bitcoin::Script.sort_p2sh_multisig_signatures(script_sig, sig_hash)

        input.script_sig = sorted
      end
    end


    private

    attr_reader :signatures

    def sig_hash_for(input, index)
      redeem_script = Bitcoin::Script.new(input.script_sig).chunks.last
      tx.signature_hash_for_input(index, redeem_script)
    end

    def script_sig_plus_sig(script_sig, signature)
      Bitcoin::Script.add_sig_to_multisig_script_sig(signature, script_sig)
    end

  end
end
