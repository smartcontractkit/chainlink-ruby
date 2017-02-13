unless Coordinator.any?
  Coordinator.create!({
    key: ENV['COORDINATOR_CLIENT_KEY'],
    secret: ENV['COORDINATOR_CLIENT_SECRET'],
    url: ENV['COORDINATOR_CLIENT_URL'],
  })
end

unless Ethereum::Account.default.present?
  Ethereum::Account.create!
end

unless KeyPair.bitcoin_default.present?
  KeyPair.create!
end

unless EthereumContractTemplate.for('ethereumBytes32')
  EthereumContractTemplate.create_contract_template 'Bytes32Oracle', Ethereum::Bytes32Oracle::SCHEMA_NAME
end

unless EthereumContractTemplate.for('ethereumInt256')
  EthereumContractTemplate.create_contract_template 'Int256Oracle', Ethereum::Int256Oracle::SCHEMA_NAME, 'int256'
end

unless EthereumContractTemplate.for('ethereumUint256')
  EthereumContractTemplate.create_contract_template 'Uint256Oracle', Ethereum::Uint256Oracle::SCHEMA_NAME, 'uint256'
end
