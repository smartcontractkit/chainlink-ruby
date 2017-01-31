describe "Ethereum oracle contract integration" do
  before { unstub_ethereum_calls }

  let(:oracle) { factory_create :ethereum_oracle }
  let(:subtask) { factory_build :subtask, adapter: oracle }
  let!(:assignment) { factory_create(:assignment, subtasks: [subtask]) }
  let(:template) { EthereumContractTemplate.for(EthereumOracle::SCHEMA_NAME) }
  let(:contract) { oracle.ethereum_contract }
  let(:genesis_tx) { contract.genesis_transaction }
  let(:oracle_value) { SecureRandom.base64 }

  before do
    allow_any_instance_of(EthereumOracle).to receive(:current_value)
      .and_return(oracle_value)
  end

  it "accepts updates which can be read after confirmation" do
    expect(contract).to be_persisted
    expect(genesis_tx).to be_persisted

    wait_for_ethereum_confirmation genesis_tx.txid
    expect {
      Ethereum::ContractConfirmer.new(contract).perform
    }.to change {
      contract.confirmed?
    }.to(true).and change {
      oracle.reload.writes.count
    }.by(+1)

    wait_for_ethereum_confirmation oracle.writes.last.txid
    result_hex = ethereum.call({
      to: contract.address,
      data: template.read_address,
      gas: 2000000,
    }).result
    result = ethereum.hex_to_bytes32(result_hex)
    expect(result).to eq(oracle_value.ljust(32, "\x00"))
  end

  context "with a contract reading from the oracle" do
    let(:account) { Ethereum::Account.default }
    let(:oracle_value) { 'UP' }

    it "accepts updates which can be read after confirmation" do
      wait_for_ethereum_confirmation genesis_tx.txid
      Ethereum::ContractConfirmer.new(contract).perform
      wait_for_ethereum_confirmation oracle.writes.last.txid

      template = ERB.new(File.read('spec/fixtures/ethereum/solidity/uptime.sol.erb'))
      address_binding = OpenStruct.new(oracle_address: contract.address).instance_eval { binding }
      solidity = template.result(address_binding)
      compiler_response = ethereum.solidity.compile("Uptime.sol" => solidity)
      compiled = compiler_response['contracts']['Uptime']
      uptime_txid = account.send_transaction({
        data: compiled['bytecode'],
        gas_limit: (compiled['gasEstimates']['creation'].last * 10),
      }).txid
      uptime_update_hash = compiled['functionHashes']['update()']
      uptime_current_hash = compiled['functionHashes']['current()']

      wait_for_ethereum_confirmation uptime_txid
      uptime_address = ethereum.get_transaction_receipt(uptime_txid).contractAddress
      update_txid = account.send_transaction({
        to: uptime_address,
        data: uptime_update_hash,
        gas_limit: 1_000_000,
      }).txid
      wait_for_ethereum_confirmation update_txid

      uptime_result = ethereum.call({
        data: uptime_current_hash,
        to: uptime_address,
        gas: 2000000,
      }).result
      result_integer = ethereum.hex_to_int(uptime_result)
      expect(result_integer).to eq(100)
    end
  end
end
