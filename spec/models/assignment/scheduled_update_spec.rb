describe Assignment::ScheduledUpdate do

  describe "validations" do
    it { is_expected.to have_valid(:assignment).when(factory_create(:assignment)) }
    it { is_expected.not_to have_valid(:assignment).when(nil) }

    it { is_expected.to have_valid(:run_at).when(Time.now) }
    it { is_expected.not_to have_valid(:run_at).when(nil) }
  end

  describe ".ready" do
    before { Timecop.freeze }
    after { Timecop.return }

    subject(:ready) { Assignment::ScheduledUpdate.ready }
    let!(:current) { factory_create :assignment_scheduled_update, run_at: Time.now, scheduled: false }
    let!(:just_passed) { factory_create :assignment_scheduled_update, run_at: 1.second.ago, scheduled: false }
    let!(:far_passed) { factory_create :assignment_scheduled_update, run_at: 1.day.ago, scheduled: false }
    let!(:future) { factory_create :assignment_scheduled_update, run_at: 1.day.from_now, scheduled: false }
    let!(:completed) { factory_create :assignment_scheduled_update, run_at: 1.day.ago, scheduled: true  }
    let!(:current_completed) { factory_create :assignment_scheduled_update, run_at: Time.now, scheduled: true  }
    let!(:premature) { factory_create :assignment_scheduled_update, run_at: 1.day.from_now, scheduled: true  }

    it "returns unscheduled jobs at or past their deadline" do
      expect(ready).to include(current)
      expect(ready).to include(just_passed)
      expect(ready).to include(far_passed)
      expect(ready).not_to include(completed)
      expect(ready).not_to include(current_completed)
      expect(ready).not_to include(premature)
    end
  end

end
