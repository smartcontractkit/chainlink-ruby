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

  describe "#mark_ready" do
    context "when the adapter has not been marked ready" do
      let(:subtask) { factory_create :uninitialized_subtask }

      it "notifies the assignment" do
        expect(subtask.assignment).to receive(:subtask_ready)
          .with(subtask)

        subtask.mark_ready
      end

      it "marks the subtask as ready" do
        expect {
          subtask.mark_ready
        }.to change {
          subtask.ready?
        }.from(false).to(true)
      end
    end

    context "when the adapter has already been marked ready" do
      let(:subtask) { factory_create :subtask }

      it "does not notify the assignment" do
        expect(subtask.assignment).not_to receive(:subtask_ready)

        subtask.mark_ready
      end

      it "does not change the subtask's ready flag" do
        expect {
          subtask.mark_ready
        }.not_to change {
          subtask.ready?
        }.from(true)
      end
    end
  end

  describe "#close_out!" do
    let(:subtask) { factory_create :subtask }

    it "tells the adapter to stop tracking it" do
      expect(subtask.adapter).to receive(:stop)
        .with(subtask)

      subtask.close_out!
    end
  end

end
