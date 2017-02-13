describe "Ethereum oracle with an uint256 value", type: :request do
  before { unstub_ethereum_calls }

  let(:coordinator_url) { "https://example.com/api/coordinator" }
  let(:coordinator) { factory_create :coordinator, url: coordinator_url }
  let(:coordinator_headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:endpoint) { "https://example.com/api/data" }
  let(:api_value) { "-79028.43" }
  let(:basic_auth) { {"username" => "steve", "password" => "rules"} }
  let(:headers) { {"App-Stuff" => "in formats"} }
  let(:result_multiplier) { nil }
  let(:assignment_params) do
    assignment_1_0_0_json({
      input_params: {
        basicAuth: basic_auth,
        fields: ['last'],
        headers: headers,
        url: endpoint,
      }.compact,
      input_type: 'httpGetJSON',
      output_params: output_params,
      output_type: Ethereum::Uint256Oracle::SCHEMA_NAME,
    })
  end

  before do
    allow(HttpRetriever).to receive(:get)
      .with(endpoint, {
        basic_auth: {
          password: basic_auth['password'],
          username: basic_auth['username'],
        },
        headers: headers,
      })
      .and_return({last: api_value}.to_json)
  end

  context "when the address and method are NOT specified" do
    let(:output_params) { {} }

    it "creates an oracle and updates it on schedule until the deadline is passed" do
      expect {
        post '/assignments/', assignment_params, coordinator_headers
      }.to change {
        coordinator.assignments.count
      }.by(+1)
      assignment = Assignment.find_by xid: response_json['xid']
      oracle = assignment.adapters.last
      contract = oracle.ethereum_contract
      genesis_txid = contract.genesis_transaction.txid
      wait_for_ethereum_confirmation genesis_txid

      expect(CoordinatorClient).to receive(:patch)
        .with("#{coordinator_url}/assignments/#{assignment.xid}", instance_of(Hash))
        .and_return(acknowledged_response)

      expect {
        run_ethereum_contract_confirmer
      }.to change {
        contract.reload.address
      }.from(nil)

      expect {
        wait_for_ethereum_confirmation oracle.writes.last.txid
      }.to change {
        get_oracle_uint oracle
      }.from(0).to(-1 * api_value.to_i)

      expect(CoordinatorClient).to receive(:post)
        .with("#{coordinator_url}/snapshots", instance_of(Hash))
        .and_return(acknowledged_response)
      run_delayed_jobs
    end

    context "when a multiplier is added" do
      let(:output_params) { { resultMultiplier: result_multiplier, } }
      let(:result_multiplier) { '100' }
      let(:api_value) { "-79028.43" }
      let(:expected_value) { 7902843 }

      it "creates an oracle and updates it on schedule until the deadline is passed" do
        expect {
          post '/assignments/', assignment_params, coordinator_headers
        }.to change {
          coordinator.assignments.count
        }.by(+1)
        assignment = Assignment.find_by xid: response_json['xid']
        oracle = assignment.adapters.last
        contract = oracle.ethereum_contract
        genesis_txid = contract.genesis_transaction.txid
        wait_for_ethereum_confirmation genesis_txid

        expect(CoordinatorClient).to receive(:patch)
          .with("#{coordinator_url}/assignments/#{assignment.xid}", instance_of(Hash))
          .and_return(acknowledged_response)

        expect {
          run_ethereum_contract_confirmer
        }.to change {
          contract.reload.address
        }.from(nil)

        expect {
          wait_for_ethereum_confirmation oracle.writes.last.txid
        }.to change {
          get_oracle_uint oracle
        }.from(0).to(expected_value)

        expect(CoordinatorClient).to receive(:post)
          .with("#{coordinator_url}/snapshots", instance_of(Hash))
          .and_return(acknowledged_response)
        run_delayed_jobs
      end
    end
  end

  context "when the address and method are specified" do
    let(:oracle_address) { ethereum_address }
    let(:oracle_method) { SecureRandom.hex(4) }
    let(:output_params) do
      {
        address: oracle_address,
        method: oracle_method
      }
    end

    before do
      allow_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction)
    end

    it "does not create a new contract" do
      expect(CoordinatorClient).not_to receive(:post)
        .with("#{coordinator_url}/oracles", instance_of(Hash))

      expect {
        post '/assignments/', assignment_params, coordinator_headers
      }.to change {
        coordinator.assignments.count
      }.by(+1)
      run_delayed_jobs
      assignment = Assignment.find_by xid: response_json['xid']
      oracle = assignment.adapters.last
      expect(oracle.ethereum_contract).to be_nil

      expect_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction) do |client, hex|
        tx = Eth::Tx.decode hex
        hex_data = bin_to_hex tx.data
        expect(hex_data).to match(/\A#{oracle_method}/)
        hex_payload = hex_data.gsub(/\A#{oracle_method}/, '')
        expect(ethereum.hex_to_int hex_payload).to eq(-1 * api_value.to_i)
      end
      expect(CoordinatorClient).to receive(:post)
        .with("#{coordinator_url}/snapshots", instance_of(Hash))
        .and_return(acknowledged_response)

      wait_for_ethereum_confirmation oracle.writes.last.txid
      run_ethereum_confirmation_watcher
      run_delayed_jobs
    end
  end
end
