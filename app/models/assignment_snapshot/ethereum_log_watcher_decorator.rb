class AssignmentSnapshot
  class EthereumLogWatcherDecorator < Decorator

    def summary
      "Event logged."
    end

    def description
      "Event: #{record.transaction_hash}##{record.log_index}"
    end

    def description_url
      Ethereum::Client.tx_url(record.transaction_hash)
    end

    def value
      record.data
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
      }
    end

    def errors
      []
    end

    def config
      record.subtask.parameters
    end

  end
end
