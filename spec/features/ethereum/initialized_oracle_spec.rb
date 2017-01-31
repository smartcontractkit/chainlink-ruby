describe "Ethereum oracle initialized with a value" do
  before { unstub_ethereum_calls }

  let(:template) { EthereumContractTemplate.for(EthereumOracle::SCHEMA_NAME) }
  let(:account) { Ethereum::Account.default }
  let(:initial_value) { ethereum.format_bytes32_hex 'Hi Mom!' }

  it "accepts updates which can be read after confirmation" do
    tx = account.send_transaction({
      data: "#{template.evm_hex}#{initial_value}",
      gas_limit: 300_000,
    })
    wait_for_ethereum_confirmation tx.txid
    receipt = ethereum.get_transaction_receipt tx.txid
    result = ethereum.call(to: receipt.contractAddress, data: template.read_address).result

    expect(ethereum.hex_to_utf8 result).to eq("Hi Mom!")
  end

end
