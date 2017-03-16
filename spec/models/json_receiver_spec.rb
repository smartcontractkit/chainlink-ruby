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

  describe "#get_status" do
    let(:subtask) { factory_build :subtask, adapter: nil }
    let!(:receiver) { factory_create :json_receiver, path: 'value', subtask: subtask }
    let(:assignment) { subtask.assignment }
    let(:assignment_snapshot) { factory_create :assignment_snapshot, assignment: assignment }
    let(:snapshot) { factory_create :adapter_snapshot, assignment_snapshot: assignment_snapshot }
    let(:previous_snapshot) { factory_create :adapter_snapshot }

    context "when the subtask is NOT the requester" do
      context "when there was a previous snapshot" do
        it "returns the snapshot that was sent to it" do
          result = receiver.get_status snapshot, previous_snapshot

          expect(result).to eq(previous_snapshot)
        end
      end

      context "when there was no previous snapshot" do
        it "a null snapshot" do
          result = receiver.get_status snapshot, nil

          expect(result.status).to be_nil
          expect(result.description).to be_nil
          expect(result.description_url).to be_nil
          expect(result.details).to be_nil
          expect(result.value).to be_nil
          expect(result.config).to be_nil
          expect(result.errors).to be_empty
          expect(result.fulfilled).to be true
        end
      end
    end

    context "when the subtask is the requester" do
      let(:value) { SecureRandom.hex }
      let(:request) { factory_create :json_receiver_request, data: {value: value} }
      let(:assignment_snapshot) do factory_create(:assignment_snapshot, {
          assignment: assignment,
          request: request,
          requester: subtask,
        })
      end

      it "returns a snapshot containing the request data" do
        result = receiver.get_status snapshot, previous_snapshot

        expect(result.summary).to eq("Snapshot triggered.")
        expect(result.description).to be_nil
        expect(result.description_url).to be_nil
        expect(result.details).to be_present
        expect(result.value).to eq value
        expect(result.errors).to be_empty
        expect(result.fulfilled).to be true
        expect(result.status).to be_nil
      end
    end
  end

end
