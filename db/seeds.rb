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
  contract_name = 'Oracle'
  code = File.read('lib/assets/contracts/Oracle.sol')
  compiled = SolidityClient.compile code
  oracle = compiled['contracts'][contract_name]

  EthereumContractTemplate.create!({
    code: code,
    construction_gas: (oracle['gasEstimates']['creation'].last * 10),
    evm_hex: oracle['bytecode'],
    json_abi: oracle['interface'],
    read_address: oracle['functionHashes']['current()'],
    solidity_abi: SolidityClient.sol_abi(contract_name, oracle['interface']),
    write_address: oracle['functionHashes']['update(bytes32)'],
  })
end
