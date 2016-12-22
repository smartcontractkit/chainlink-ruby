describe AdapterSnapshotHandler do
  let(:handler) { AdapterSnapshotHandler.new(snapshot) }

  describe "#perform" do
    let!(:snapshot) { factory_create :adapter_snapshot, assignment_snapshot: assignment_snapshot }
    let(:assignment_snapshot) { factory_create :assignment_snapshot }
    let(:assignment) { snapshot.adapter_assignment.assignment }
    let(:adapter) { snapshot.adapter_assignment.adapter }
    let(:adapter_response) do
      {
        fulfilled: false,
        xid: snapshot.xid,
      }
    end

    before do
      allow_any_instance_of(ExternalAdapter).to receive(:get_status)
        .with(snapshot)
        .and_return(hashie adapter_response)
    end

    context "when the adapter responds without information" do
      it "marks itself as unfulfilled" do
        expect {
          handler.perform
        }.not_to change {
          snapshot.fulfilled
        }.from(false)
      end

      it "records the information" do
        expect {
          handler.perform
        }.not_to change {
          snapshot.value
        }
      end

      it "does NOT notify the coordinator" do
        expect_any_instance_of(CoordinatorClient).not_to receive(:snapshot)

        handler.perform
      end
    end

    context "when the adapter responds with more information" do
      let(:value) { SecureRandom.hex }
      let(:details) { {key: SecureRandom.hex} }
      let(:adapter_response) do
        {
          fulfilled: true,
          details: details,
          value: value,
          xid: snapshot.xid,
        }
      end

      it "marks itself as fulfilled" do
        expect {
          handler.perform
        }.to change {
          snapshot.fulfilled
        }.from(false).to(true)
      end

      it "records the information" do
        expect {
          handler.perform
        }.to change {
          snapshot.value
        }.from(nil).to(value).and change {
          snapshot.details_json
        }.from(nil).to(details.to_json)
      end
    end

    context "when nothing is returned by the adapter" do
      let(:adapter_response) { nil }

      it "sends out a notifaction" do
        expect(Notification).to receive_message_chain(:delay, :snapshot_failure)
          .with(assignment, nil)

        handler.perform
      end
    end

    context "when errors are returned by the adapter" do
      let(:errors) { ["foo", "bar"] }
      let(:adapter_response) { { errors: errors } }

      it "sends out a notifaction" do
        expect(Notification).to receive_message_chain(:delay, :snapshot_failure)
          .with(assignment, errors)

        handler.perform
      end
    end
  end
end
