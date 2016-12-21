describe AdapterAssignment, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:adapter).when(factory_create(:external_adapter), factory_create(:ethereum_oracle), factory_create(:custom_expectation)) }
    it { is_expected.not_to have_valid(:adapter).when(nil) }

    it { is_expected.to have_valid(:adapter_params).when(nil, {}) }

    it { is_expected.to have_valid(:assignment).when(factory_create(:assignment)) }
    it { is_expected.not_to have_valid(:assignment).when(nil) }

    it { is_expected.to have_valid(:index).when(0, 1000) }
    it { is_expected.not_to have_valid(:index).when(nil, -1, 0.1) }
    context "when sharing an assignment" do
      let(:old) { factory_create :adapter_assignment }
      subject { AdapterAssignment.new assignment: old.assignment }

      it { is_expected.not_to have_valid(:index).when(old.index) }
    end
  end

end
