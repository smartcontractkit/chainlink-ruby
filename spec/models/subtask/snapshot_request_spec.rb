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

end
