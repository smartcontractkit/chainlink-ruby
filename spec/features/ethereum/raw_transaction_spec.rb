describe "building and signing transactions in the app, broadcasting to a node" do
  before { unstub_ethereum_calls }

  let(:key) { Eth::Key.new }
  let(:pub) { key.public_bytes }
  let(:address) { key.to_address }
  let(:account) { Ethereum::Account.default }


  it "signs a valid ethereum transaction" do
    gas_price = ethereum.gas_price
    value = Ethereum::WEI_PER_ETHER
    response = account.send_transaction({
      gas_limit: 1_000_000,
      to: address,
      value: value,
    })
    funding_txid = response.txid
    wait_for_ethereum_confirmation funding_txid
    block_number = ethereum.get_transaction_receipt(funding_txid).blockNumber

    tx = Eth::Tx.new({
      data: '',
      gas_price: gas_price,
      nonce: 0,
      gas_limit: 100000,
      to: Ethereum::Account.default.address,
      value: (value * 0.9).to_i,
    })
    tx.sign key
    # tx.check_low_s

    response = ethereum.send_raw_transaction(tx.encoded.bth)
    expect(response.error).to be_nil
    return_txid = response.txid
    wait_for_ethereum_confirmation return_txid
    block_number = ethereum.get_transaction_receipt(return_txid).blockNumber
    expect(return_txid).to be_present
    expect(block_number).to be_present
  end
end
