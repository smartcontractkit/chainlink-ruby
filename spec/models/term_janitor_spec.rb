describe TermJanitor, type: :model do

  describe ".clean_up" do
    let(:janitor) { instance_double TermJanitor }
    let!(:failed_term) { factory_create :term, status: Term::FAILED }
    let!(:expired_term) { factory_create :term, start_at: 1.day.ago, end_at: 1.second.ago, status: Term::IN_PROGRESS }
    let!(:in_progress_term) { factory_create :term, end_at: 1.day.from_now, status: Term::IN_PROGRESS}

    it "creates a new janitor for any in progress term past it's deadline" do
      expect(TermJanitor).to receive_message_chain(:delay, :perform)
        .with(expired_term.id)

      TermJanitor.clean_up
    end
  end

  describe ".perform" do
    let(:assignment) { factory_create :ethereum_assignment }
    let(:term) { factory_create :term, expectation: assignment, status: status }

    before do
      allow(Term).to receive(:find)
        .with(term.id)
        .and_return(term)
    end

    context "when the term is in progress" do
      let(:status) { Term::IN_PROGRESS }

      it "updates the term's status to completed" do
        expect(term).to receive(:update_status)
          .with(Term::COMPLETED)

        TermJanitor.perform(term.id)
      end
    end

    context "when the term is no longer in progress" do
      let(:status) { Term::COMPLETED }

      it "updates the term's status to failed" do
        expect(term).not_to receive(:update_status)

        TermJanitor.perform(term.id)
      end
    end
  end
end
