describe AdapterAssignment, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:adapter).when(factory_create(:external_adapter), factory_create(:ethereum_oracle), factory_create(:custom_expectation)) }
    it { is_expected.not_to have_valid(:adapter).when(nil) }

    it { is_expected.to have_valid(:parameters).when(nil, {}, {SecureRandom.hex => SecureRandom.hex}) }

    it { is_expected.to have_valid(:assignment).when(factory_create(:assignment)) }
    it { is_expected.not_to have_valid(:assignment).when(nil) }

    it { is_expected.to have_valid(:index).when(0, 1000) }
    it { is_expected.not_to have_valid(:index).when(nil, -1, 0.1) }
    context "when sharing an assignment" do
      let(:old) { factory_create :adapter_assignment }
      subject { AdapterAssignment.new assignment: old.assignment }

      it { is_expected.not_to have_valid(:index).when(old.index) }
    end

    context "when the adapter gets an error" do
      let(:adapter_assignment) { factory_build :adapter_assignment }
      let(:adapter) { adapter_assignment.adapter }
      let(:assignment) { adapter_assignment.assignment }
      let(:remote_error_message) { 'big errors. great job.' }

      it "includes the adapter error" do
        expect(adapter).to receive(:start)
          .with(adapter_assignment)
          .and_return(create_assignment_response errors: [remote_error_message])

        adapter_assignment.save

        full_messages = adapter_assignment.errors.full_messages
        expect(full_messages).to include("Adapter##{adapter_assignment.index} Error: #{remote_error_message}")
      end
    end
  end

end
