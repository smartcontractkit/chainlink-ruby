describe HealthCheck do
  let(:check) { HealthCheck.new }

  describe "#eth_unconfirmed_tx_count" do
    before do
      factory_create :ethereum_transaction
      factory_create :ethereum_transaction, confirmations: 50
    end

    it "queries all the unconfirmed ethereum transactions" do
      expect(check.eth_unconfirmed_tx_count).to eq(1)
    end
  end

  describe "#status" do
    subject { check.status }

    context "when nothing out of the ordinary is noticed" do
      it { is_expected.to eq('OK') }
    end

    context "when the confirmed transaction count is greater than 0" do
      before do
        expect(EthereumTransaction).to receive_message_chain(:unconfirmed, :count)
          .and_return(1)
      end

      it { is_expected.to eq('Questionable') }
    end

    context "when there is a difference in block height" do
      let(:internal) { 10 }
      let(:external) { 11 }
      before do
        expect_any_instance_of(Ethereum::Client).to receive(:current_block_height)
          .and_return(internal)

        expect(HealthCheck).to receive(:eth_external_block_height)
          .and_return(external)
      end

      it { is_expected.to eq('Questionable') }
    end

    context "when there is no internal block height" do
      before do
        allow_any_instance_of(Ethereum::Client).to receive(:current_block_height)
          .and_return(nil)
      end

      it { is_expected.to eq('ERROR') }
    end

    context "when there are errors" do
      before { check.errors[1] = 'enough' }

      it { is_expected.to eq('ERROR') }
    end
  end

end
