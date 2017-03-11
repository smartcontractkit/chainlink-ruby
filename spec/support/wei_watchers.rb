module SpecHelpers

  def ww_params_from_log_event(event, options = {})
    {
      address: event['address'],
      blockHash: event['blockHash'],
      blockNumber: ethereum.hex_to_uint(event['blockNumber']),
      data: event['data'],
      logIndex: ethereum.hex_to_uint(event['logIndex']),
      transactionHash: event['transactionHash'],
      transactionIndex: ethereum.hex_to_uint(event['transactionIndex']),
    }.merge options
  end

  def ethereum_log(options = {})
    {
      address: options.fetch(:ethereumAddress, ethereum_address),
      blockHash: options.fetch(:blockHash, ethereum_txid),
      blockNumber: options.fetch(:blockNumber, rand(1_000_000)),
      data: options.fetch(:data, ethereum_txid),
      logIndex: options.fetch(:logIndex, rand(1_000)),
      topics: options.fetch(:topics, [ethereum_txid]),
      transactionHash: options.fetch(:transactionHash, ethereum_txid),
      transactionIndex: options.fetch(:transactionIndex, rand(1_000)),
      transactionLogIndex: options.fetch(:transactionLogIndex, rand(1_000)),
      type: options.(:type, "mined"),
    }
  end

end
