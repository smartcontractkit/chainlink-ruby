describe SnapshotsController, type: :controller do

  describe "#create" do
    let(:assignment) { factory_create :assignment }
    let(:details_hash) { {SecureRandom.hex => SecureRandom.hex} }
    let(:xid) { SecureRandom.uuid }
    let(:snapshot_params) do
      {
        assignment_xid: "#{assignment.xid}=9321",
        details: details_hash,
        status: Term::IN_PROGRESS,
        summary: '%%!ASSIGNMENT_NAME!%% is termendous.',
        value: 101.01,
        xid: xid
      }
    end

    context "when the adapter is authorized" do
      before { external_adapter_log_in assignment.adapters.first }

      it "creates a snapshot for the assignment" do
        expect {
          post :create, snapshot_params
        }.to change {
          assignment.snapshots.count
        }.by(+1)

        expect(response).to be_success
      end

      it "saves all the parameters passed in" do
        expect {
          post :create, snapshot_params
        }.to change {
          AssignmentSnapshot.count
        }.by(+1)

        snapshot = AssignmentSnapshot.last
        expect(snapshot).to be_fulfilled

        expect(snapshot.details).to eq(details_hash)
        expect(snapshot.status).to eq(snapshot_params[:status])
        expect(snapshot.summary).to eq("#{assignment.name} is termendous.")
        expect(snapshot.value).to eq(snapshot_params[:value].to_s)
        expect(snapshot.xid).to eq(xid)
      end
    end

    context "when the coordinator is authorized" do
      let(:snapshot_params) do
        {
          assignment_id: assignment.xid
        }
      end

      before { coordinator_log_in assignment.coordinator }

      it "creates a snapshot for the assignment" do
        expect {
          post :create, snapshot_params
        }.to change {
          assignment.snapshots.count
        }.by(+1)

        expect(response).to be_success
      end

      it "saves all the parameters passed in" do
        expect {
          post :create, snapshot_params
        }.to change {
          AssignmentSnapshot.count
        }.by(+1)

        snapshot = AssignmentSnapshot.last
        expect(snapshot).not_to be_fulfilled
      end
    end

    context "when not authorized" do
      it "does NOT create a new record" do
        expect {
          post :create, snapshot_params
        }.not_to change {
          assignment.snapshots.count
        }

        expect(response).not_to be_success
      end
    end
  end

  describe "#update" do
    let!(:snapshot) { factory_create :assignment_snapshot }
    let(:assignment) { snapshot.assignment }
    let(:details_hash) { {SecureRandom.hex => SecureRandom.hex} }
    let(:xid) { snapshot.xid }
    let(:snapshot_params) do
      {
        assignment_xid: assignment.xid,
        details: details_hash,
        id: xid,
        status: Term::IN_PROGRESS,
        summary: '%%!ASSIGNMENT_NAME!%% is termendous.',
        value: 101.01,
        xid: xid,
      }
    end

    context "when the adapter is authorized" do
      before { external_adapter_log_in assignment.adapters.first }

      it "does NOT create a new record" do
        expect {
          patch :update, snapshot_params
        }.not_to change {
          assignment.snapshots.count
        }

        expect(response).to be_success
      end

      it "saves all the parameters passed in" do
        expect {
          patch :update, snapshot_params
        }.to change {
          snapshot.reload.fulfilled?
        }.from(false).to(true)

        expect(snapshot.details).to eq(details_hash)
        expect(snapshot.status).to eq(snapshot_params[:status])
        expect(snapshot.summary).to eq("#{assignment.name} is termendous.")
        expect(snapshot.value).to eq(snapshot_params[:value].to_s)
        expect(snapshot.xid).to eq(xid)
      end

      context "when the snapshot is already fulfilled" do
        before { snapshot.update_attributes fulfilled: true }

        it "does NOT respond successfully" do
          expect {
            patch :update, snapshot_params
          }.not_to change {
            assignment.snapshots.count
          }

          expect(response).not_to be_success
        end
      end
    end

    context "when not authorized" do
      it "does NOT respond successfully" do
        expect {
          patch :update, snapshot_params
        }.not_to change {
          assignment.snapshots.count
        }

        expect(response).not_to be_success
      end
    end
  end

  describe "#show" do
    let(:snapshot) { factory_create :assignment_snapshot }
    let(:assignment) { snapshot.assignment }
    let(:snapshot_params) do
      {
        id: snapshot.xid
      }
    end

    context "when authenticated as a coordinator" do
      before { coordinator_log_in assignment.coordinator }

      it "responds with all of the snapshot's information" do
        get :show, snapshot_params

        expect(response).to be_success
        expect(response_json[:xid]).to eq snapshot.xid
      end

      context "when the snapshot cannot be found" do
        let(:snapshot_params) do
          {
            id: (snapshot.xid + "!")
          }
        end

        it "responds with an error message" do
          get :show, snapshot_params

          expect(response).not_to be_success
          expect(response_json[:errors]).to include "No snapshot found."
        end
      end
    end

    context "when authenticated as a coordinator" do
      before { coordinator_log_in factory_create(:coordinator) }

      it "responds with an error message" do
        get :show, snapshot_params

        expect(response).not_to be_success
        expect(response_json[:errors]).to include "No snapshot found."
      end
    end

    context "when authenticated as an adapter" do
      before { external_adapter_log_in assignment.adapters.first }

      it "responds with all of the snapshot's information" do
        get :show, snapshot_params

        expect(response).not_to be_success
      end
    end

    context "when unauthenticated" do
      before { log_out_basic_auth }

      it "responds with all of the snapshot's information" do
        get :show, snapshot_params

        expect(response).not_to be_success
      end
    end
  end

end
