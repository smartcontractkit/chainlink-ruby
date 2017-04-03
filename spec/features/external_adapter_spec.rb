describe "delegating a subtask to an external adapter", type: :request do
  let(:adapter) { external_adapters(:basic) }
  let(:adapter_type) { adapter.assignment_type }
  let(:output_params) { {SecureRandom.hex => SecureRandom.hex} }
  let(:coordinator) { factory_create :coordinator }
  let(:headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:assignment_params) do
    assignment_1_0_0_json({
      input_params: {
        fields: ['last'],
        url: 'http://api.smartcontract.com/v0/assignments',
      }.compact,
      input_type: 'httpGetJSON',
      output_params: output_params,
      output_type: adapter_type.name,
    })
  end

  it "passes all of the necessary parameters" do
    expect(ExternalAdapterClient).to receive(:post) do |url, params|
      expect(url).to eq(adapter.url + '/subtasks')

      expect(params[:body][:xid]).to be_present
      adapter_params = params.with_indifferent_access[:body][:data]
      expect(adapter_params).to eq(output_params.with_indifferent_access)

      http_response
    end

    expect {
      post '/assignments/', assignment_params, headers
    }.to change {
      coordinator.assignments.count
    }.by(+1)
  end
end
