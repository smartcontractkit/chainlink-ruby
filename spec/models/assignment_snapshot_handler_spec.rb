describe AssignmentSnapshotHandler do
  let!(:subtask1) { factory_build :subtask, assignment: nil }
  let!(:subtask2) { factory_build :subtask, assignment: nil }
  let!(:subtask3) { factory_build :subtask, assignment: nil }
  let(:snapshot) { factory_create(:assignment_snapshot, assignment: assignment) }
  let(:handler) { AssignmentSnapshotHandler.new snapshot }
  let(:assignment) { factory_create :assignment, subtasks: [subtask1, subtask2, subtask3] }
  let(:adapter_snapshot1) { snapshot.adapter_snapshots[0] }
  let(:adapter_snapshot2) { snapshot.adapter_snapshots[1] }
  let(:adapter_snapshot3) { snapshot.adapter_snapshots[2] }


  describe "#start" do
    it "starts the first adapter snapshot" do
      expect(adapter_snapshot1).to receive(:start)

      handler.start
    end
  end

  describe "#adapter_response" do
    let(:response) { { "result" => { SecureRandom.hex => SecureRandom.hex } } }
    let(:adapter_snapshot) { adapter_snapshot1 }

    before do
      expect(assignment.adapters.count).to eq(3)
      expect(adapter_snapshot.reload.assignment_snapshot).to eq(snapshot.reload)
      adapter_snapshot.update_attributes!({
        details: response,
        fulfilled: true,
      })
    end

    context "when the response contains errors" do
      let(:errors) { ["foo", "bar"] }
      let(:response) { { "errors" => errors } }

      it "sends out a notifaction" do
        expect(Notification).to receive_message_chain(:delay, :snapshot_failure)
          .with(assignment, errors)

        handler.adapter_response(adapter_snapshot)
      end

      it "saves the adapter response as the assignment snapshot's details" do
        expect {
          handler.adapter_response(adapter_snapshot)
        }.to change {
          snapshot.reload.details
        }.from(nil).to(response)
      end

      it "marks the assignment snapshot as failed" do
        expect {
          handler.adapter_response(adapter_snapshot)
        }.to change {
          snapshot.reload.progress
        }.from(AssignmentSnapshot::STARTED).to(AssignmentSnapshot::FAILED)
      end

      it "does NOT pass the response to another adapter" do
        expect_any_instance_of(AdapterSnapshot).not_to receive(:start)

        handler.adapter_response(adapter_snapshot)
      end
    end

    context "when the adapter is the last adapter" do
      let(:adapter_snapshot) { adapter_snapshot3 }

      before do
        adapter_snapshot.update_attributes({
          description: SecureRandom.hex,
          description_url: SecureRandom.hex,
          summary: SecureRandom.hex,
          value: SecureRandom.hex,
        })

        snapshot.update_attributes adapter_index: adapter_snapshot.index
      end

      it "sends out a notifaction" do
        expect(Notification).not_to receive(:delay)

        handler.adapter_response(adapter_snapshot)
      end

      it "saves the adapter response as the assignment snapshot's details" do
        expect {
          handler.adapter_response(adapter_snapshot)
        }.to change {
          snapshot.reload.details
        }.to(response).and change {
          snapshot.summary
        }.to(adapter_snapshot.summary).and change {
          snapshot.description
        }.to(adapter_snapshot.description).and change {
          snapshot.description_url
        }.to(adapter_snapshot.description_url).and change {
          snapshot.value
        }.to(adapter_snapshot.value)
      end

      it "marks the assignment snapshot as completed" do
        expect {
          handler.adapter_response(adapter_snapshot)
        }.to change {
          snapshot.reload.progress
        }.from(AssignmentSnapshot::STARTED).to(AssignmentSnapshot::COMPLETED).and change {
          snapshot.reload.fulfilled
        }.from(false).to(true)
      end

      it "does NOT pass the response to another adapter" do
        expect_any_instance_of(AdapterSnapshot).not_to receive(:start)

        handler.adapter_response(adapter_snapshot)
      end

      it "does not update the status of the assignment" do
        expect_any_instance_of(Assignment).not_to receive(:update_status)

        handler.adapter_response(adapter_snapshot)
      end

      context "and the adapter has a status" do
        before do
          adapter_snapshot.update_attributes status: Assignment::COMPLETED
        end

        it "does not update the status of the assignment" do
          expect_any_instance_of(Assignment).to receive(:update_status) do |assignment, status|
            expect(assignment).to eq(snapshot.assignment)
            expect(status).to eq(Assignment::COMPLETED)
          end

          handler.adapter_response(adapter_snapshot)
        end
      end
    end

    context "when the there are subsequent adapters in the assignment" do
      before { snapshot.reload }

      it "sends out a notifaction" do
        expect(Notification).not_to receive(:delay)

        handler.adapter_response(adapter_snapshot)
      end

      it "saves the adapter response as the assignment snapshot's details" do
        expect {
          handler.adapter_response(adapter_snapshot)
        }.not_to change {
          snapshot.reload.details
        }.from(nil)
      end

      it "changes the snapshot's adapter index" do
        expect {
          handler.adapter_response(adapter_snapshot)
        }.to change {
          snapshot.reload.adapter_index
        }.from(adapter_snapshot.index).to(adapter_snapshot2.index)
      end

      it "passes the response on to the next adapter" do
        expect_any_instance_of(AdapterSnapshot).to receive(:start) do |instance, params|
          expect(instance).to eq(adapter_snapshot2)
          expect(params).to eq(response)
        end

        handler.adapter_response(adapter_snapshot)
      end
    end
  end

end
