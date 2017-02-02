describe Term, type: :model do
  describe "validations" do
    it { is_expected.to have_valid(:contract).when(contracts(:basic)) }
    it { is_expected.not_to have_valid(:contract).when(nil) }

    it { is_expected.to have_valid(:end_at).when(Time.now) }
    it { is_expected.not_to have_valid(:end_at).when(nil) }

    it { is_expected.to have_valid(:name).when("1") }
    it { is_expected.not_to have_valid(:name).when(nil, '') }

    it { is_expected.to have_valid(:start_at).when(100.years.ago) }
    it { is_expected.not_to have_valid(:start_at).when(nil) }

    it { is_expected.to have_valid(:status).when('completed', 'failed', 'in progress') }
    it { is_expected.not_to have_valid(:status).when('other') }

    context "when the contract and name are the same as another term" do
      let(:older_term) do
        Term.create({
          start_at: 1.day.ago, end_at: 1.day.from_now,
          contract: contracts(:basic), name: '1', tracking: "seo"
        })
      end

      it "is not valid" do
        term = Term.new(contract: older_term.contract, name: older_term.name)

        expect(term).not_to be_valid
        expect(term.errors.full_messages).to include("Name has already been taken")
      end
    end

    context "when the term start date is before the end date" do
      it "is not valid" do
        term = Term.new start_at: 1.day.from_now, end_at: 1.day.ago

        expect(term).not_to be_valid
        expect(term.errors.full_messages).to include("Start at must be before end at")
      end
    end

    context "when the term is no longer in progress" do
      let(:term) { factory_create :term, status: Term::FAILED }

      it "does not allow the status to be updated" do
        expect(term.update_attributes status: Term::COMPLETED).to be_falsey

        expect(term.errors.full_messages).to include("Status is no longer in progress")
      end
    end
  end

  describe ".expired" do
    subject { Term.expired }
    let!(:failed_term) { factory_create :term, end_at: 1.day.ago, start_at: 2.days.ago, status: Term::FAILED }
    let!(:completed_term) { factory_create :term, end_at: 1.day.ago, start_at: 2.days.ago, status: Term::COMPLETED }
    let!(:expired_term) { factory_create :term, end_at: 1.second.ago, start_at: 1.day.ago, status: Term::IN_PROGRESS }
    let!(:in_progress_term) { factory_create :term, end_at: 1.day.from_now, start_at: 1.day.ago, status: Term::IN_PROGRESS}

    it { is_expected.to include expired_term }
    it { is_expected.not_to include in_progress_term }
    it { is_expected.not_to include failed_term }
    it { is_expected.not_to include completed_term }
  end

  describe ".in_progress" do
    subject { Term.in_progress }
    let!(:failed_term) { factory_create :term, end_at: 1.day.ago, status: Term::FAILED, start_at: 2.days.ago }
    let!(:completed_term) { factory_create :term, end_at: 1.day.ago, status: Term::COMPLETED, start_at: 2.days.ago }
    let!(:in_progress_term) { factory_create :term, end_at: 1.day.from_now, status: Term::IN_PROGRESS}

    it { is_expected.to include in_progress_term }
    it { is_expected.not_to include failed_term }
    it { is_expected.not_to include completed_term }
  end

  describe "#update_status" do
    let(:contract) { term.contract }
    let(:term) { factory_create :term, status: status, expectation: expectation }
    let(:expectation) { factory_create :assignment }

    context "when the term is completed" do
      let(:status) { Term::COMPLETED }

      it "does not change the term status" do
        expect {
          term.update_status Term::FAILED
        }.not_to change {
          term.reload.status
        }
      end

      it "does not notify the contract of status change" do
        expect(term.contract).not_to receive(:delay)

        term.update_status Term::FAILED
      end

      it "returns false if the same status is already set" do
        expect(term.update_status Term::FAILED).to be_falsey
      end

      it "does not re-notify the contract when the same state is submitted" do
        expect(term.contract).not_to receive(:delay)

        term.update_status Term::COMPLETED
      end

      it "returns true if the same status is already set" do
        expect(term.update_status Term::COMPLETED).to eq(Term::COMPLETED)
      end
    end

    context "when the term is failed" do
      let(:status) { Term::FAILED }

      it "does not change the term status" do
        expect {
          term.update_status Term::COMPLETED
        }.not_to change {
          term.reload.status
        }
      end

      it "does not notify the contract of status change" do
        expect(term.contract).not_to receive(:delay)

        term.update_status Term::COMPLETED
      end

      it "returns false if the same status is already set" do
        expect(term.update_status Term::COMPLETED).to be_falsey
      end

      it "does not re-notify the contract when the same state is submitted" do
        expect(term.contract).not_to receive(:delay)

        term.update_status Term::FAILED
      end

      it "returns true if the same status is already set" do
        expect(term.update_status Term::FAILED).to be_truthy
      end
    end

    context "when the term is in progress" do
      let(:status) { Term::IN_PROGRESS }
      let(:new_status) { Term::COMPLETED }

      it "changes the term's status" do
        expect {
          term.update_status Term::COMPLETED
        }.to change {
          term.status
        }.from(Term::IN_PROGRESS).to(Term::COMPLETED)
      end

      it "notifies the contract of status change" do
        expect(term.contract).to receive_message_chain(:delay, :check_status)

        term.update_status new_status
      end

      it "notifiies the contract coordinator" do
        expect(contract.coordinator).to receive(:update_term)
          .with(term.id)

        term.update_status new_status
      end

      it "notifies the expectation to clean up" do
        expect(term.expectation).to receive_message_chain(:delay, :close_out!)
          .with(new_status)

        term.update_status new_status
      end

      it "does not close out the term when flagged as not to" do
        expect(term.expectation).not_to receive(:delay)

        term.update_status new_status, false
      end
    end
  end

  describe "#outcome_signatures" do
    let(:term) { factory_create :term, status: status }
    let(:success_outcome) { nil }
    let(:failure_outcome) { nil }
    let(:signatures) { double }

    context "when the term is complete" do
      let(:status) { Term::COMPLETED }

      context "when there are associated outcomes" do
        let!(:success_outcome) { factory_create :escrow_outcome, term: term, result: 'success' }
        let!(:failure_outcome) { factory_create :escrow_outcome, term: term, result: 'failure' }

        it "asks the success outcome" do
          expect_any_instance_of(EscrowOutcome).to receive(:signatures) do |instance|
            expect(instance).to eq(success_outcome)
          end

          term.outcome_signatures
        end
      end

      context "when there are not associated outcomes" do
        it "returns an empty array" do
          expect(term.outcome_signatures).to eq([])
        end
      end
    end

    context "when the term has failed" do
      let(:status) { Term::FAILED }

      context "when there are associated outcomes" do
        let!(:success_outcome) { factory_create :escrow_outcome, term: term, result: 'success' }
        let!(:failure_outcome) { factory_create :escrow_outcome, term: term, result: 'failure' }

        it "asks the failure outcome" do
          expect_any_instance_of(EscrowOutcome).to receive(:signatures) do |instance|
            expect(instance).to eq(failure_outcome)
          end

          term.outcome_signatures
        end
      end

      context "when there are not associated outcomes" do
        it "returns an empty array" do
          expect(term.outcome_signatures).to eq([])
        end
      end
    end

    context "when the term is still in progress" do
      let(:status) { Term::IN_PROGRESS }

      it "raises an error" do
        expect {
          term.outcome_signatures
        }.to raise_error("No signatures, term is still in progress!")
      end
    end
  end
end
