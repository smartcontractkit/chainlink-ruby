module SpecHelpers
  def unstub_ethereum_calls
    allow(EthereumClient).to receive(:post).and_call_original
    allow_any_instance_of(EthereumClient).to receive(:gas_price).and_call_original
    allow_any_instance_of(EthereumClient).to receive(:get_transaction_count).and_call_original
  end
end
