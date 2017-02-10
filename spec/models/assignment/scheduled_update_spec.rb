describe Assignment::ScheduledUpdate do

  describe "validations" do
    it { is_expected.to have_valid(:assignment).when(factory_create(:assignment)) }
    it { is_expected.not_to have_valid(:assignment).when(nil) }

    it { is_expected.to have_valid(:run_at).when(Time.now) }
    it { is_expected.not_to have_valid(:run_at).when(nil) }
  end

end
