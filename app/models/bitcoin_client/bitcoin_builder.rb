class BitcoinClient
  class BitcoinBuilder

    def initialize(options)
      perform
      self.tx = tx_with_payload
    end

    def tx
      @tx ||= Bitcoin::Protocol::Tx.new
    end

    def hex
      tx.to_payload.unpack('H*').first
    end

    def id
      tx.hash
    end


    private

    attr_writer :tx

    def tx_with_payload
      Bitcoin::Protocol::Tx.new tx.to_payload
    end

  end
end
