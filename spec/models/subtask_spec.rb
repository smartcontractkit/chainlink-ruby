describe Subtask, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:adapter).when(factory_create(:external_adapter), factory_create(:ethereum_oracle), factory_create(:custom_expectation)) }
    it { is_expected.not_to have_valid(:adapter).when(nil) }

    it { is_expected.to have_valid(:parameters).when(nil, {}, {SecureRandom.hex => SecureRandom.hex}) }

    it { is_expected.to have_valid(:assignment).when(factory_create(:assignment)) }
    it { is_expected.not_to have_valid(:assignment).when(nil) }

    it { is_expected.to have_valid(:index).when(0, 1000) }
    it { is_expected.not_to have_valid(:index).when(nil, -1, 0.1) }
    context "when sharing an assignment" do
      let(:old) { factory_create :subtask }
      subject { Subtask.new assignment: old.assignment }

      it { is_expected.not_to have_valid(:index).when(old.index) }
    end

    context "when the adapter gets an error" do
      let(:subtask) { factory_build :subtask }
      let(:adapter) { subtask.adapter }
      let(:assignment) { subtask.assignment }
      let(:remote_error_message) { 'big errors. great job.' }

      it "includes the adapter error" do
        expect(adapter).to receive(:start)
          .with(subtask)
          .and_return(create_assignment_response errors: [remote_error_message])

        subtask.save

        full_messages = subtask.errors.full_messages
        expect(full_messages).to include("Adapter##{subtask.index} Error: #{remote_error_message}")
      end
    end
  end

  describe "on create" do
    let(:subtask) { factory_build :subtask }

    it "changes marks itself initialized based on the adapter" do
      expect {
        subtask.save
      }.to change {
        subtask.ready?
      }.from(false).to(true)
    end
  end

end
