describe Contract, type: :model do

  describe "#initialize" do
    it { is_expected.to have_valid(:coordinator).when(factory_create(:coordinator)) }
    it { is_expected.not_to have_valid(:coordinator).when(nil) }

    it { is_expected.to have_valid(:json_body).when(contract_json) }
    it { is_expected.not_to have_valid(:json_body).when(nil, '') }

    it { is_expected.to have_valid(:status).when('in progress', 'completed', 'failed') }
    it { is_expected.not_to have_valid(:status).when('foobar') }

    it { is_expected.to have_valid(:xid).when('foobar') }
    it { is_expected.not_to have_valid(:xid).when(nil, '') }
  end

  describe "#check_status" do
    let(:contract) { factory_create :contract }
    let!(:term1) { factory_create :term, contract: contract, status: status1 }
    let!(:term2) { factory_create :term, contract: contract, status: status2 }

    before { contract.reload }

    context "when any term is failed" do
      let(:status1) { Term::FAILED }
      let(:status2) { Term::IN_PROGRESS }

      it "marks the contract failed" do
        expect {
          contract.check_status
        }.to change {
          contract.status
        }.from(Contract::IN_PROGRESS).to(Contract::FAILED)
      end
    end

    context "when some terms are in progress and none are failed" do
      let(:status1) { Term::COMPLETED }
      let(:status2) { Term::IN_PROGRESS }

      it "marks the contract failed" do
        expect {
          contract.check_status
        }.not_to change {
          contract.status
        }
      end
    end

    context "when all terms are completed" do
      let(:status1) { Term::COMPLETED }
      let(:status2) { Term::COMPLETED }

      it "marks the contract failed" do
        expect {
          contract.check_status
        }.to change {
          contract.status
        }.from(Contract::IN_PROGRESS).to(Contract::COMPLETED)
      end
    end
  end

  describe "#completeness" do
    let(:comp1) { Term.new(status: Term::COMPLETED) }
    let(:comp2) { Term.new(status: Term::COMPLETED) }
    let(:prog1) { Term.new(status: Term::IN_PROGRESS) }
    let(:fail1) { Term.new(status: Term::FAILED) }
    let(:fail2) { Term.new(status: Term::FAILED) }
    let(:contract) { Contract.new terms: [comp1, comp2, prog1, fail1, fail2] }

    it "returns the percentage of completed contracts" do
      expect(contract.completeness).to eq(0.4)
    end
  end
end
