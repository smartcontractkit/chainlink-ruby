describe Subtask::SnapshotRequest do

  describe "validations" do
    it { is_expected.to have_valid(:data).when(nil, {a: 1}) }

    it { is_expected.to have_valid(:subtask).when(factory_create :subtask) }
    it { is_expected.not_to have_valid(:subtask).when(nil) }
  end

  describe "on create" do
    let(:request) { factory_build :subtask_snapshot_request }
    let(:subtask) { request.subtask }

    it "requests a snapshot from its adapter" do
      expect(subtask).to receive_message_chain(:delay, :snapshot_requested)
        .with(request)

      request.save
    end
  end

  describe "assignment snapshot API" do
    let(:data) { snapshot_hash }
    let(:request) { factory_create :subtask_snapshot_request, data: data }
    let(:subtask) { request.subtask }

    it "conforms to the assignment snapshot API" do
      expect(request.value).to eq(data[:value])
      expect(request.summary).to eq(data[:summary])
      expect(request.description).to eq(data[:description])
      expect(request.description_url).to eq(data[:description_url])
      expect(request.details).to eq(data[:details])
      expect(request.config).to eq(subtask.parameters)
    end
  end

end
