describe Assignment::RequestHandler do
  describe "#perform" do
    let(:coordinator) { factory_create :coordinator }
    let(:body_json) { assignment_1_0_0_json }
    let(:request) { factory_build :assignment_request, coordinator: coordinator, body_json: body_json }
    let(:handler) { Assignment::RequestHandler.perform(request) }
    let(:assignment) { handler.assignment }

    it "builds an assignment schedule" do
      expect(assignment.schedule).to be_present
    end

    context "when the assingment is pre-version 1.0" do
      let(:body_json) { assignment_0_1_0_json }

      before { request.save }

      it "creates a list of adapters" do
        expect(assignment.adapters.size).to eq(1)
      end
    end

    context "when the assignment is version 1.0 or greater" do
      let!(:assignment) { handler.assignment }
      let(:body_json) { assignment_1_0_0_json }

      before do
        request.tap(&:save).reload
      end

      it "creates a list of adapters" do
        expect(assignment.adapters.size).to eq 2
      end

      it "does not create any scheduled updates" do
        expect(assignment.scheduled_updates.count).to eq(0)
      end

      it "sets the subtask type" do
        expect(assignment.subtasks.first.task_type).to eq('basic')
      end
    end

    context "when scheduled update times are specified" do
      let(:update_times) { [1.week.from_now, 27.weeks.from_now, 53.weeks.from_now].map(&:to_i) }
      let(:body_json) { assignment_1_0_0_json schedule: {runAt: update_times.map(&:to_s)} }

      before { request.save }

      it "creates a set of scheduled updates" do
        updates = assignment.scheduled_updates
        expect(updates.size).to eq(update_times.size)
        expect(updates.map(&:run_at).map(&:to_i)).to match_array(update_times)
      end

      it "sets the end time" do
        expect(assignment.end_at.to_i).to eq(update_times.max)
      end
    end

    context "when a subtask is invalid" do
      let(:body_json) { assignment_1_0_0_json }
      let(:first_type) { 'basic' }
      let(:second_type) { 'seo' }

      before do
        allow(AdapterBuilder).to receive(:perform)
          .with(first_type, nil)
          .and_call_original

        allow(AdapterBuilder).to receive(:perform)
          .with(second_type, nil)
          .and_return(nil)
      end

      it "does not save the request" do
        request.save

        expect(request).not_to be_persisted
      end

      it "does return the assignment" do
        expect(assignment).to be_present
      end

      it "rolls back the creation of the already created subtasks" do
        expect_any_instance_of(ExternalAdapter).to receive(:stop) do |adapter, subtask|
          expect(adapter.assignment_type.name).to eq(first_type)
        end

        request.save
      end

      it "marks the handler invalid" do
        expect(handler).not_to be_valid
      end

      it "returns the errors" do
        expect(assignment.errors).not_to be_empty
        expect(handler.errors).to eq(assignment.errors)
      end

      it "still sets the subtask's end time" do
        expect(assignment.subtasks.first.end_at).to be_present
      end
    end
  end
end
