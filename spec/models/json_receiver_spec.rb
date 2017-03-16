describe JsonReceiver do

  describe "validations" do
    it { is_expected.to have_valid(:path).when(['whatever'], 'andEver') }
    it { is_expected.not_to have_valid(:path).when(nil, '', [], [nil], ['and', nil]) }
  end

  describe "on create" do
    let(:receiver) { factory_build :json_receiver }

    it "generates an external ID" do
      expect {
        receiver.save
      }.to change {
        receiver.xid
      }.from(nil)
    end
  end

  describe "#snapshot_requested" do
    let(:subtask) { factory_build :subtask, adapter: nil }
    let(:receiver) { factory_create :json_receiver, subtask: subtask }
    let(:assignment) { receiver.assignment }
    let(:request) { factory_create :json_receiver_request }

    it "creates a new event" do
      expect {
        receiver.snapshot_requested request
      }.to change {
        assignment.snapshots.count
      }.by(+1)

      snapshot = assignment.snapshots.last
      expect(snapshot.request).to eq(request)
      expect(snapshot.requester).to eq(subtask)
    end
  end

end
