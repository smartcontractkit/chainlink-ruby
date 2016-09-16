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
end
