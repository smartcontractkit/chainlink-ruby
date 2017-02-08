module MockAndStubHelpers

  RSpec.configure do |config|
    config.before do
      stubbed_response = {from: "spec/support/mocks_and_stubs.rb"}.to_json

      allow_any_instance_of(BlockCypherClient).to receive(:get_transaction_hex)
        .and_return("01000000000000000000")

      allow_any_instance_of(BlockCypher::Api).to receive(:event_webhook_subscribe)
        .and_return('blah')
        # .and_return(canned_block_cypher_response)

      allow_any_instance_of(BlockCypher::Api).to receive(:blockchain_transaction)
        .and_return('blah')
        # .and_return(block_cypher_blockchain_transaction SecureRandom.hex)

      allow(CoordinatorClient).to receive(:get)
        .and_return(http_response body: {}.to_json)
      allow(CoordinatorClient).to receive(:post)
        .and_return(http_response body: {}.to_json)
      allow(CoordinatorClient).to receive(:patch)
        .and_return(http_response body: {}.to_json)

      allow(Ethereum::Client).to receive(:post)
        .with("/", instance_of(Hash))
        .and_return(http_response body: ethereum_create_transaction_response.to_json)
      allow_any_instance_of(Ethereum::Client).to receive(:gas_price)
        .and_return(22_333)
      allow_any_instance_of(Ethereum::Client).to receive(:get_transaction_count)
        .and_return(rand 100_000)

      allow(ExternalAdapterClient).to receive(:post)
        .and_return(http_response body: stubbed_response)
      allow(ExternalAdapterClient).to receive(:get)
        .and_return(http_response body: stubbed_response)
      allow(ExternalAdapterClient).to receive(:delete)
        .and_return(http_response body: stubbed_response)

      allow(HttpRetriever).to receive(:get)
        .and_return(stubbed_response)

      allow(WeiWatchersClient).to receive(:get)
        .and_return(stubbed_response)
      allow(WeiWatchersClient).to receive(:post)
        .and_return(stubbed_response)
    end

    config.around bitcoin_network: :bitcoin do |example|
      Bitcoin.network = :bitcoin
      example.run
      Bitcoin.network = :testnet3
    end
  end

  def unstub_ethereum_calls
    allow(Ethereum::Client).to receive(:post).and_call_original
    allow_any_instance_of(Ethereum::Client).to receive(:gas_price).and_call_original
    allow_any_instance_of(Ethereum::Client).to receive(:get_transaction_count).and_call_original
  end

end
