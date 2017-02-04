describe AssignmentSchedule, type: :model do
  describe "validations" do
    it { is_expected.to have_valid(:assignment).when(factory_create(:assignment)) }
    it { is_expected.not_to have_valid(:assignment).when(nil) }

    it { is_expected.to have_valid(:minute).when('0', '59', '*') }
    it { is_expected.not_to have_valid(:minute).when(nil, '') }

    it { is_expected.to have_valid(:hour).when('0', '23', '*') }
    it { is_expected.not_to have_valid(:hour).when(nil, '') }

    it { is_expected.to have_valid(:day_of_month).when('0', '6', '*', nil) }

    it { is_expected.to have_valid(:month_of_year).when('0', '6', '*', nil) }

    it { is_expected.to have_valid(:day_of_week).when('0', '6', '*', nil) }
  end

  describe "on create" do
    let(:schedule) { AssignmentSchedule.new hour: '0', minute: '0' }

    it "will set default attributes other than hour and minute" do
      expect {
        schedule.save
      }.to change {
        schedule.day_of_month
      }.from(nil).to('*').and change {
        schedule.month_of_year
      }.from(nil).to('*').and change {
        schedule.day_of_week
      }.from(nil).to('*')
    end
  end

  describe ".at" do
    let!(:hour) { 17 }
    let!(:minute) { 8 }
    let!(:any_time) { factory_create :assignment_schedule, minute: '*', hour: '*' }
    let!(:any_minute) { factory_create :assignment_schedule, minute: '*', hour: hour }
    let!(:any_hour) { factory_create :assignment_schedule, minute: minute, hour: '*' }
    let!(:exact_time) { factory_create :assignment_schedule, minute: minute, hour: hour }
    let!(:padded_time) { factory_create :assignment_schedule, minute: ('0' + minute.to_s), hour: ('0' + hour.to_s) }
    let!(:exact_time_off_minute) { factory_create :assignment_schedule, minute: (minute + 1), hour: hour }
    let!(:exact_time_off_hour) { factory_create :assignment_schedule, minute: minute, hour: (hour + 1) }
    let!(:off_time) { factory_create :assignment_schedule, minute: (minute - 1), hour: (hour + 1)}

    it "matches each padding and catch-alls" do
      list = AssignmentSchedule.at(minute, hour)

      expect(list).to include any_time
      expect(list).to include any_minute
      expect(list).to include any_hour
      expect(list).to include exact_time
      expect(list).to include padded_time
      expect(list).not_to include exact_time_off_minute
      expect(list).not_to include exact_time_off_hour
      expect(list).not_to include off_time
    end
  end
end
