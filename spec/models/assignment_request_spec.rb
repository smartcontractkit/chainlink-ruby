describe AssignmentRequest, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:assignment).when(factory_build(:assignment)) }
    it { is_expected.not_to have_valid(:assignment).when(nil) }

    it { is_expected.to have_valid(:body_hash).when(SecureRandom.hex) }
    it { is_expected.not_to have_valid(:body_hash).when(nil, '') }

    it { is_expected.to have_valid(:body_json).when(assignment_json) }
    it { is_expected.not_to have_valid(:body_json).when(nil, '', {}.to_json) }

    it { is_expected.to have_valid(:signature).when(SecureRandom.hex) }
    it { is_expected.not_to have_valid(:signature).when(nil, '') }
  end

end
