describe AssignmentRequest, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:assignment).when(factory_build(:assignment)) }
    it { is_expected.not_to have_valid(:assignment).when(nil) }

    it { is_expected.to have_valid(:body_hash).when(SecureRandom.hex) }
    it { is_expected.not_to have_valid(:body_hash).when(nil, '') }

    it { is_expected.to have_valid(:body_json).when(assignment_0_1_0_json) }
    it { is_expected.to have_valid(:body_json).when(assignment_1_0_0_json) }
    it { is_expected.not_to have_valid(:body_json).when(nil, '', {}.to_json) }

    it { is_expected.to have_valid(:signature).when(SecureRandom.hex) }
    it { is_expected.not_to have_valid(:signature).when(nil, '') }
  end

  describe "on creation" do
    let(:coordinator) { factory_create :coordinator }
    let(:request) { factory_build :assignment_request, coordinator: coordinator }

    it "signs the body hash" do
      expect {
        request.save
      }.to change {
        request.signature
      }.from(nil)
    end

    it "creates an associated assignment" do
      expect {
        request.save
      }.to change {
        request.assignment
      }.from(nil)

      expect(request.assignment.parameters).to eq(request.body[:assignmentParams])
    end

    it "associates the coordinator with the assignment" do
      expect {
        request.save
      }.to change {
        coordinator.reload.assignments.count
      }.by(+1)
    end

    it "creates an assignment schedule" do
      expect {
        request.save
      }.to change {
        AssignmentSchedule.count
      }.by(+1)
    end
  end

end
