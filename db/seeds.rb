unless Coordinator.any?
  Coordinator.create!({
    key: ENV['COORDINATOR_CLIENT_KEY'],
    secret: ENV['COORDINATOR_CLIENT_SECRET'],
    url: ENV['COORDINATOR_CLIENT_URL'],
  })
end

unless EthereumAccount.default.present?
  EthereumAccount.create!
end

unless KeyPair.bitcoin_default.present?
  KeyPair.create!
end

unless EthereumContractTemplate.any?
  EthereumContractTemplate.create_contract_template
end
