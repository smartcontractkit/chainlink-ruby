class AssignmentSnapshot
  class EthereumOracleWriteDecorator < Decorator

    def summary
      return if assignment.blank?
      if value.present?
        "#{assignment.name} updated its value to \"#{value}\"."
      else
        "#{assignment.name} updated its value to be empty."
      end
    end

    def description
      "Blockchain record: #{txid}"
    end

    def description_url
      EthereumClient.tx_url txid
    end

    def details
      {value: value, txid: txid}
    end

    def xid
      txid
    end

    def value
      record.value
    end


    private

    def assignment
      record.assignment
    end

    def txid
      record.txid
    end

  end
end
