describe AssignmentBuilder, type: :model do
  let(:coordinator) { factory_create :coordinator }

  describe "#perform" do
    let(:builder) do
      AssignmentBuilder.new coordinator, assignment_hash({
        adapterParams: params,
        adapterType: type,
        endAt: end_at,
      })
    end
    let(:params) { {} }
    let(:type) { assignment_types(:basic).name }
    let(:end_at) { 1.day.from_now }

    it "creates an assignment" do
      expect {
        builder.perform
      }.to change {
        coordinator.assignments.count
      }.by(+1)
    end

    context "when given invalid parameters" do
      let(:end_at) { nil }

      it "does NOT create a new assignment" do
        expect {
          builder.perform
        }.not_to change {
          Assignment.count
        }
      end

      it "returs the assignment with errors attached" do
        assignment = builder.perform

        expect(assignment.errors).to be_present
        expect(assignment.errors.full_messages).to include("Start at must be before end at")
      end
    end
  end

end
