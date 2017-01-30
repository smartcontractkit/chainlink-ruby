describe AssignmentScheduler, type: :model do
  describe "#perform" do
    before { Timecop.freeze }
    after { Timecop.return }

    let(:now) { Time.now }
    let!(:current1) { factory_create :assignment_schedule, minute: now.min, hour: now.hour }
    let!(:current2) { factory_create :assignment_schedule, minute: now.min, hour: '*' }
    let!(:current3) do
      factory_create(:assignment_schedule, minute: now.min, hour: now.hour).tap do |schedule|
        schedule.assignment.update_attributes(status: Assignment::COMPLETED)
      end
    end
    let!(:current4) do
      factory_create(:assignment_schedule, minute: now.min, hour: now.hour).tap do |schedule|
        schedule.assignment.update_attributes(status: Assignment::FAILED)
      end
    end
    let!(:past1) { factory_create :assignment_schedule, minute: (now.min - 1), hour: now.hour }
    let!(:past2) { factory_create :assignment_schedule, minute: now.min, hour: (now.hour - 1) }
    let!(:past3) { factory_create :assignment_schedule, minute: (now.min - 1), hour: '*' }
    let!(:past4) do
      factory_create(:assignment_schedule, minute: (now.min - 1), hour: now.min).tap do |schedule|
        schedule.assignment.update_attributes(status: Assignment::COMPLETED)
      end
    end
    let!(:future1) { factory_create :assignment_schedule, minute: (now.min + 1), hour: now.hour }
    let!(:future2) { factory_create :assignment_schedule, minute: now.min, hour: (now.hour + 1) }
    let!(:future3) { factory_create :assignment_schedule, minute: (now.min + 1), hour: '*' }
    let!(:future4) do
      factory_create(:assignment_schedule, minute: (now.min + 1), hour: now.min).tap do |schedule|
        schedule.assignment.update_attributes(status: Assignment::FAILED)
      end
    end

    it "only queues jobs currently matching the hour and minute" do
      good_list = [current1, current2].map(&:assignment_id)

      allow(AssignmentScheduler).to receive_message_chain(:delay, :check_status) do |id|
        expect(good_list).to include(id)
        good_list -= [id]
      end

      AssignmentScheduler.perform

      expect(good_list.size).to eq(0)
    end
  end

  describe "#check_status" do
    let!(:assignment) { factory_create :assignment }

    it "checks the status of the instance provided" do
      expect_any_instance_of(Assignment).to receive(:check_status) do |receiver|
        expect(assignment).to eq(receiver)
      end

      AssignmentScheduler.check_status assignment.id
    end
  end
end
