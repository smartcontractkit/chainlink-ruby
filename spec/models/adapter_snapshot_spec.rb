describe AdapterSnapshot do

  describe "validations" do
    it { is_expected.to have_valid(:assignment_snapshot).when(factory_create(:assignment_snapshot)) }
    it { is_expected.not_to have_valid(:assignment_snapshot).when(nil) }

    it { is_expected.to have_valid(:subtask).when(factory_create(:subtask)) }
    it { is_expected.not_to have_valid(:subtask).when(nil) }
    context "when a similar adapter assignment already exists" do
      let(:old) { factory_create :adapter_snapshot }
      subject { AdapterSnapshot.new assignment_snapshot: old.assignment_snapshot }
      it { is_expected.not_to have_valid(:subtask).when(old.subtask) }
    end

    it { is_expected.to have_valid(:description).when(nil, '', Faker::Lorem.sentence) }

    it { is_expected.to have_valid(:description_url).when(nil, '', Faker::Lorem.sentence) }

    it { is_expected.to have_valid(:details).when(nil, {}, {SecureRandom.hex => SecureRandom.hex}) }

    it { is_expected.to have_valid(:fulfilled).when(true, false) }

    it { is_expected.to have_valid(:summary).when(nil, '', Faker::Lorem.sentence) }

    it { is_expected.to have_valid(:value).when(nil, '', 42, SecureRandom.base64) }
  end

  describe "#xid" do
    let(:adapter_snapshot) { factory_create :adapter_snapshot }
    let(:assignment_snapshot) { adapter_snapshot.assignment_snapshot }
    let(:subtask) { adapter_snapshot.subtask }

    it "equals the assignment snapshot ID and adapter index" do
      expect(adapter_snapshot.xid).to eq("#{assignment_snapshot.xid}=#{subtask.index}")
    end
  end

  describe "#start" do
    let(:adapter_snapshot) { factory_create :adapter_snapshot }
    let(:subtask) { adapter_snapshot.subtask }

    context "when parameters are passed in" do
      let(:params) { { SecureRandom.hex => SecureRandom.hex } }

      it "merges them with the adapter's parameters" do
        expect_any_instance_of(AdapterSnapshotHandler).to receive(:perform)
          .with(params.merge({
            config: subtask.parameters
          }))

        adapter_snapshot.start(params)
      end
    end

    context "when no parameters are passed in" do
      it "merges them with the adapter's parameters" do
        expect_any_instance_of(AdapterSnapshotHandler).to receive(:perform)
          .with({
            config: subtask.parameters
          })

        adapter_snapshot.start
      end
    end
  end

end
