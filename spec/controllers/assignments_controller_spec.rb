describe AssignmentsController, type: :controller do
  describe "#create" do
    let(:coordinator) { Coordinator.create }
    let(:assignment_params) { assignment_hash }

    before { coordinator_log_in coordinator }

    context "when the assignment params are valid" do
      it "returns a successful status" do
        post :create, assignment: assignment_params

        expect(response).to be_success
        expect(response_json['xid']).to be_present
      end

      it "creates a new assignment for the coordinator" do
        expect {
          post :create, assignment: assignment_params
        }.to change {
          coordinator.reload.assignments.count
        }.by(+1)
      end
    end

    context "when the assignment params are NOT valid" do
      let(:assignment_params) { assignment_hash assignmentHash: nil }

      it "returns an unsuccessful status" do
        post :create, assignment: assignment_params

        expect(response).to be_bad_request
      end

      it "does not create a new assignment" do
        expect {
          post :create, assignment: assignment_params
        }.not_to change {
          Assignment.count
        }
      end

      it "returns the errors associated" do
        post :create, assignment: assignment_params

        expect(response_json['errors']).to be_present
      end
    end
  end

  describe "#update" do
    let(:assignment) { factory_create :assignment }
    let(:new_status) { Term::COMPLETED }
    let(:assignment_params) do
      {
        id: assignment.xid,
        status: new_status,
        xid: assignment.xid,
      }
    end

    context "when the assignment is in progress and authenticated" do
      before { input_adapter_log_in assignment.adapter }

      it "updates the assignment" do
        expect {
          patch :update, assignment_params
        }.to change {
          assignment.reload.status
        }.from(Assignment::IN_PROGRESS).to(new_status)

        expect(response).to be_success
      end

      it "creates a status update for the assignment" do
        expect {
          patch :update, assignment_params
        }.to change {
          assignment.snapshots.count
        }.by(+1)

        expect(assignment.snapshots.last.status).to eq(new_status)
      end
    end

    context "when the assignment is NOT in progress" do
      before do
        input_adapter_log_in assignment.adapter
        assignment.update_attributes status: Assignment::FAILED
      end

      it "responds with an error" do
        expect {
          patch :update, assignment_params
        }.not_to change {
          assignment.reload.status
        }

        expect(response).to be_bad_request
        expect(response_json.errors).to include('Status is no longer in progress')
      end
    end

    context "when the requester is not authorized" do
      before { input_adapter_log_in }

      it "responds with an error" do
        expect {
          patch :update, assignment_params
        }.not_to change {
          assignment.reload.status
        }

        expect(response).to be_not_found
        expect(response_json.errors).to include('Assignment not found')
      end
    end
  end

end
