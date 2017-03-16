class AdapterBuilder

  def self.perform(type, params)
    new.perform type, params
  end

  def perform(type, params)
    if adapter = ExternalAdapter.for_type(type)
      adapter
    elsif [CustomExpectation::SCHEMA_NAME, 'custom'].include? type
      CustomExpectation.new(body: params)
    elsif [EthereumOracle::SCHEMA_NAME, 'oracle'].include? type
      EthereumOracle.new(body: params)
    elsif [JsonAdapter::SCHEMA_NAME].include? type
      JsonAdapter.new(body: params)
    elsif [JsonReceiver::SCHEMA_NAME].include? type
      JsonReceiver.new(body: params)
    elsif [Ethereum::Bytes32Oracle::SCHEMA_NAME].include? type
      Ethereum::Bytes32Oracle.new(body: params)
    elsif [Ethereum::Uint256Oracle::SCHEMA_NAME].include? type
      Ethereum::Uint256Oracle.new(body: params)
    elsif [Ethereum::Int256Oracle::SCHEMA_NAME].include? type
      Ethereum::Int256Oracle.new(body: params)
    elsif [Ethereum::LogWatcher::SCHEMA_NAME].include? type
      Ethereum::LogWatcher.new(body: params)
    else
      raise "No adapter type found for \"#{type}\""
    end
  end

end
