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
    let(:body_json) { assignment_0_1_0_json }
    let(:request) { factory_build :assignment_request, coordinator: coordinator, body_json: body_json }

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

    context "when the assingment is pre-version 1.0" do
      let(:body_json) { assignment_0_1_0_json }

      before { request.save }

      it "creates a list of assignments" do
        expect(request.reload.assignment.adapters.size).to eq(1)
      end
    end

    context "when the assignment is version 1.0 or greater" do
      let(:body_json) { assignment_1_0_0_json }

      before { request.save }

      it "creates a list of assignments" do
        expect(request.reload.assignment.adapters.size).to eq 2
      end

      it "does not create any scheduled updates" do
        expect(request.reload.assignment.scheduled_updates.count).to eq(0)
      end
    end

    context "when scheduled update times are specified" do
      let(:update_times) { [1.week.from_now, 27.weeks.from_now, 53.weeks.from_now].map(&:to_i) }
      let(:body_json) { assignment_1_0_0_json schedule: {runAt: update_times.map(&:to_s)} }

      before { request.save }

      it "creates a set of scheduled updates" do
        updates = request.reload.assignment.scheduled_updates
        expect(updates.count).to eq(update_times.size)
        expect(updates.map(&:run_at).map(&:to_i)).to match_array(update_times)
      end

      it "creates a list of assignments" do
        expect(request.assignment.end_at.to_i).to eq(update_times.max)
      end
    end
  end

end
