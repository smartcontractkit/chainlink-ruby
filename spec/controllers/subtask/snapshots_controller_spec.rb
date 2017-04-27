require 'subtask/snapshots_controller'

describe Subtask::SnapshotsController, type: :controller do

  describe "#create" do
    let(:adapter) { factory_create :external_adapter }
    let(:subtask) { factory_create :subtask, adapter: adapter }
    let(:assignment) { subtask.assignment }
    let(:details_hash) { {SecureRandom.hex => SecureRandom.hex} }
    let(:xid) { SecureRandom.uuid }
    let(:snapshot_params) do
      {
        subtask_id: subtask.xid,
        details: details_hash,
        status: Term::IN_PROGRESS,
        summary: '%%!ASSIGNMENT_NAME!%% is termendous.',
        value: 101.01,
        xid: xid
      }
    end

    context "when the adapter is authorized" do
      before { external_adapter_log_in adapter }

      it "creates a snapshot for the assignment" do
        expect {
          run_generated_jobs {
            post :create, snapshot_params
          }
        }.to change {
          assignment.reload.snapshots.count
        }.by(+1)

        expect(response).to be_success
      end

      it "saves all the parameters passed in" do
        post :create, snapshot_params
        snapshot = Subtask::SnapshotRequest.last

        expect(snapshot.details).to eq(details_hash)
        expect(snapshot.status).to eq(snapshot_params[:status])
        expect(snapshot.summary).to eq('%%!ASSIGNMENT_NAME!%% is termendous.')
        expect(snapshot.value).to eq(snapshot_params[:value].to_s)
      end
    end

    context "when the adapter is NOT authorized" do
      before { external_adapter_log_in factory_create(:external_adapter) }

      it "does not create an assignment" do
        expect {
          post :create, snapshot_params
        }.not_to change {
          assignment.snapshots.count
        }

        expect(response).to be_not_found
      end
    end
  end
end
