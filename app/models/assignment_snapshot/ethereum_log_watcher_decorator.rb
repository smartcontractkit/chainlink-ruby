class AssignmentSnapshot
  class EthereumLogWatcherDecorator < Decorator

    def summary
      "Event logged." if record_present?
    end

    def description
      if record_present?
        "Event: #{record.transaction_hash}##{record.log_index}"
      end
    end

    def description_url
      if record_present?
        Ethereum::Client.tx_url(record.transaction_hash)
      end
    end

    def value
      record.data if record_present?
    end

    def details
      {
        address: record.address,
        blockHash: record.block_hash,
        blockNumber: record.block_number,
        data: record.data,
        logIndex: record.log_index,
        transactionHash: record.transaction_hash,
        transactionIndex: record.transaction_index,
        value: record.data,
      } if record_present?
    end

    def errors
      []
    end

    def config
      record.subtask.parameters if record_present?
    end

    def present?
      true
    end


    private

    def record_present?
      record.present?
    end

  end
end
