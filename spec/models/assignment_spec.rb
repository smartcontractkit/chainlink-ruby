describe Assignment, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:adapter).when(factory_create(:input_adapter)) }
    it { is_expected.not_to have_valid(:adapter).when(nil) }

    it { is_expected.to have_valid(:json_parameters).when({a: 1}.to_json, nil) }
    it { is_expected.not_to have_valid(:json_parameters).when('blah') }

    it { is_expected.to have_valid(:status).when('completed', 'failed', 'in progress') }
    it { is_expected.not_to have_valid(:status).when('other') }

    it { is_expected.to have_valid(:term).when(factory_build(:term), nil) }

    context "when the adapter gets an error" do
      let(:assignment) { factory_build :assignment }
      let(:remote_error_message) { 'big errors. great job.' }

      it "includes the adapter error" do
        expect(assignment.adapter).to receive(:start)
          .with(assignment)
          .and_return(create_assignment_response errors: [remote_error_message])

        assignment.save

        expect(assignment.errors.full_messages).to include("Adapter: #{remote_error_message}")
      end
   end

    context "when the term start date is before the end date" do
      it "is not valid" do
        term = Term.new start_at: 1.day.from_now, end_at: 1.day.ago

        expect(term).not_to be_valid
        expect(term.errors.full_messages).to include("Start at must be before end at")
      end
    end

    context "when the assignment is no longer in progress" do
      let(:assignment) { factory_create :failed_assignment }

      it "does not allow the status to be updated" do
        expect(assignment.update_attributes status: Assignment::COMPLETED).to be_falsey

        expect(assignment.errors.full_messages).to include("Status is no longer in progress")
      end
    end
  end

  describe "on create" do
    let(:assignment) { factory_build :assignment }

    it "assigns an XID" do
      expect {
        assignment.tap(&:save).reload
      }.to change {
        assignment.xid
      }.from(nil)
    end

    it "sends the work over to the adapter" do
      expect(assignment.adapter).to receive(:start)
        .with(assignment)
        .and_return(create_assignment_response)

      assignment.save
    end

    it "does NOT create a schedule" do
      expect {
        assignment.tap(&:save).reload
      }.not_to change {
        assignment.schedule
      }.from(nil)
    end

    context "when the assignment has a schedule" do
      let(:assignment) { factory_build :assignment, schedule_attributes: schedule_params }
      let(:schedule_params) { factory_attrs :assignment_schedule, assignment: nil }

      it "creates a schedule" do
        expect {
          assignment.tap(&:save).reload
        }.to change {
          AssignmentSchedule.count
        }

        expect(assignment.schedule).to eq(AssignmentSchedule.last)
      end
    end
  end

  describe "#check_status" do
    let(:assignment) { factory_create :assignment }

    it "creates a new status record" do
      expect {
        assignment.check_status
      }.to change {
        assignment.snapshots.count
      }.by(+1)
    end
  end

  describe "#close_out!" do
    let(:assignment) { factory_create :assignment }
    let(:adapter) { assignment.adapter }
    let(:status) { Assignment::COMPLETED }

    it "closes out via the adapter" do
      expect(adapter).to receive(:stop)
        .with(assignment)

      assignment.close_out!
    end

    it "moves the assignment into the failed state" do
      expect {
        assignment.close_out! status
      }.to change {
        assignment.status
      }.from(Assignment::IN_PROGRESS).to(status)
    end
  end

  describe "#update_status" do
    let(:assignment) { factory_create :assignment, term: term }
    let(:status) { Assignment::COMPLETED }

    context "when the assignment does NOT have a term" do
      let(:term) { nil }

      it "creates an assignment snapshot" do
        expect {
          assignment.update_status status
        }.to change {
          assignment.snapshots.count
        }.by(+1)
      end

      it "updates the assignment's status" do
        expect {
          assignment.update_status status
        }.to change {
          assignment.status
        }.from(Assignment::IN_PROGRESS).to(Assignment::COMPLETED)
      end
    end

    context "when the assignment does have a term" do
      let(:term) { factory_create :term }

      before do
        expect(assignment.term).to receive(:update_status)
          .and_return(updated)
      end

      context "when the status successfully updates" do
        let(:updated) { true }

        it "creates an assignment snapshot" do
          expect {
            assignment.update_status status
          }.to change {
            assignment.snapshots.count
          }.by(+1)
        end

        it "updates the assignment's status" do
          expect {
            assignment.update_status status
          }.to change {
            assignment.status
          }.from(Assignment::IN_PROGRESS).to(Assignment::COMPLETED)
        end
      end

      context "when the status successfully does NOT update" do
        let(:updated) { false }

        it "does NOT create a snapshot" do
          expect {
            assignment.update_status status
          }.not_to change {
            assignment.snapshots.count
          }
        end

        it "updates the assignment's status" do
          expect {
            assignment.update_status status
          }.not_to change {
            assignment.status
          }.from(Assignment::IN_PROGRESS)
        end
      end
    end
  end

end
