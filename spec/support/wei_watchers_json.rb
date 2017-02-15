module SpecHelpers
  def event_hash(options = {})
    {
      address: options.fetch(:address, ethereum_address),
      blockHash: options.fetch(:block_hash, ethereum_txid),
      blockNumber: options.fetch(:block_number, rand(1_000_000_000)),
      data: options.fetch(:data, SecureRandom.hex),
      logIndex: options.fetch(:log_index, rand(1_000)),
      subscription: options.fetch(:subscription, SecureRandom.uuid),
      topics: options.fetch(:topics, [ethereum_txid]),
      transactionHash: options.fetch(:transaction_hash, ethereum_txid),
      transactionIndex: options.fetch(:transaction_index, rand(100)),
    }
  end
end
