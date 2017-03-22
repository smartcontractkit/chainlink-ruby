describe ExternalAdapter, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:assignment_type).when(factory_create(:assignment_type)) }
    it { is_expected.not_to have_valid(:assignment_type).when(nil) }

    it { is_expected.to have_valid(:url).when(Faker::Internet.domain_name) }
    it { is_expected.not_to have_valid(:url).when('', nil) }
  end

  describe "on create" do
    let(:adapter) { factory_build :external_adapter }

    it "assigns username and password for authentication" do
      expect {
        adapter.save
      }.to change {
        adapter.username
      }.from(nil).and change {
        adapter.password
      }.from(nil)
    end
  end

  describe ".for_type" do
    let!(:adapter1) { factory_create :external_adapter }
    let!(:adapter2) { factory_create :external_adapter }
    let!(:adapter3) { factory_create :external_adapter }

    it "returns the adapter matching that type" do
      expect(ExternalAdapter.for_type adapter1.type).to eq(adapter1)
      expect(ExternalAdapter.for_type adapter2.type).to eq(adapter2)
      expect(ExternalAdapter.for_type adapter3.type).to eq(adapter3)

      expect(ExternalAdapter.for_type (adapter3.type + '1')).to be_nil
    end
  end

  describe "#get_status" do
    let!(:adapter) { factory_create :external_adapter }
    let!(:subtask) { factory_create :subtask, adapter: adapter }
    let!(:adapter_snapshot) { factory_create :adapter_snapshot, assignment_snapshot: assignment_snapshot, subtask: subtask }
    let!(:assignment_snapshot) { factory_create :assignment_snapshot, requester: requester, request: request }

    context "when the subtask's requester is the subtask itself" do
      let!(:request) { factory_create :subtask_snapshot_request }
      let(:requester) { subtask }

      it "does NOT make an external call" do
        expect(ExternalAdapterClient).not_to receive(:post)

        adapter.get_status adapter_snapshot
      end

      it "returns the subtask's request" do
        result = adapter.get_status adapter_snapshot

        expect(result).to eq(request)
      end
    end

    context "when the subtask's requester is NOT the subtask itself" do
      let(:request) { nil }
      let(:requester) { nil }

      it "does make an external call" do
        expect(ExternalAdapterClient).to receive(:post)

        adapter.get_status adapter_snapshot
      end
    end
  end

end
