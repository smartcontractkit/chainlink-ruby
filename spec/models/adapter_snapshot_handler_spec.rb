describe AdapterSnapshotHandler do
  let(:handler) { AdapterSnapshotHandler.new(snapshot.reload) }

  describe "#perform" do
    let!(:snapshot) { factory_create :adapter_snapshot, assignment_snapshot: assignment_snapshot }
    let(:assignment_snapshot) { factory_create :assignment_snapshot }
    let(:assignment) { snapshot.subtask.assignment }
    let(:adapter) { snapshot.subtask.adapter }
    let(:params) { Hash.new }
    let(:adapter_response) do
      {
        fulfilled: false,
        xid: snapshot.xid,
      }
    end

    before do
      allow_any_instance_of(ExternalAdapter).to receive(:get_status)
        .with(snapshot, params)
        .and_return(hashie adapter_response)
    end

    context "when the adapter responds without information" do
      it "marks itself as unfulfilled" do
        expect {
          handler.perform params
        }.not_to change {
          snapshot.fulfilled
        }.from(false)
      end

      it "records the information" do
        expect {
          handler.perform params
        }.not_to change {
          snapshot.value
        }
      end

      it "does NOT pass the response back to the assignment snapshot" do
        expect(assignment_snapshot).not_to receive(:adapter_response)

        handler.perform params
      end
    end

    context "when the adapter responds with more information" do
      let(:value) { SecureRandom.hex }
      let(:details) { {key: SecureRandom.hex} }
      let(:status) { 'uh huh' }
      let(:adapter_response) do
        {
          fulfilled: true,
          details: details,
          value: value,
          status: status,
          xid: snapshot.xid,
        }
      end

      it "marks itself as fulfilled" do
        expect {
          handler.perform params
        }.to change {
          snapshot.fulfilled
        }.from(false).to(true)
      end

      it "records the information" do
        expect {
          handler.perform params
        }.to change {
          snapshot.value
        }.from(nil).to(value).and change {
          snapshot.details_json
        }.from(nil).to(details.to_json).and change {
          snapshot.status
        }.from(nil).to(status)
      end

      it "passes the response up to the assignment snapshot" do
        expect_any_instance_of(AssignmentSnapshot).to receive(:adapter_response) do |instance|
          expect(instance).to eq(assignment_snapshot)
        end

        handler.perform params
      end
    end

    context "when nothing is returned by the adapter" do
      let(:adapter_response) { nil }

      it "sends out a notifaction" do
        expect(Notification).to receive_message_chain(:delay, :snapshot_failure)
          .with(assignment, ["No response received."])

        handler.perform params
      end

      it "does NOT pass the response up to the assignment snapshot" do
        expect(assignment_snapshot).not_to receive(:adapter_response)

        handler.perform params
      end
    end

    context "when errors are returned by the adapter" do
      let(:errors) { ["foo", "bar"] }
      let(:adapter_response) { { errors: errors } }

      it "sends out a notifaction" do
        expect(Notification).to receive_message_chain(:delay, :snapshot_failure)
          .with(assignment, errors)

        handler.perform params
      end

      it "passes the response up to the assignment snapshot" do
        expect_any_instance_of(AssignmentSnapshot).to receive(:adapter_response) do |instance|
          expect(instance).to eq(assignment_snapshot)
        end

        handler.perform params
      end
    end
  end
end
