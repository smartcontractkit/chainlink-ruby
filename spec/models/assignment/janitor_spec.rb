describe Assignment::Janitor do

  describe "#schedule_clean_up" do
    it "schedules a sweep job to run" do
      expect(Assignment::Janitor).to receive_message_chain(:delay, :clean_up)

      Assignment::Janitor.schedule_clean_up
    end
  end

  describe ".clean_up" do
    let(:id) { rand 1_000_000 }

    it "schedules a clean up for each expired assignment" do
      expect(Assignment).to receive_message_chain(:expired, :termless, :pluck)
        .with(:id)
        .and_return([id])

      expect(Assignment::Janitor).to receive_message_chain(:delay, :perform)
        .with(id)

      Assignment::Janitor.clean_up
    end
  end

  describe "#perform" do
    let(:assignment) { factory_create :assignment, end_at: 1.minute.ago }
    let(:janitor) { Assignment::Janitor.new assignment }

    it "closes out the assignment" do
      expect(assignment).to receive(:close_out!)

      janitor.perform
    end
  end

end
