describe EthereumContract, type: :model do

  describe "validations" do
    subject { EthereumContract.new adapter_type: EthereumOracle::SCHEMA_NAME }

    it { is_expected.to have_valid(:address).when("0x#{SecureRandom.hex(20)}", nil) }
    it { is_expected.not_to have_valid(:address).when('', '0x', SecureRandom.hex(20), "0x#{SecureRandom.hex(19)}") }

    it { is_expected.to have_valid(:owner).when(factory_create(:ethereum_oracle), factory_create(:ethereum_bytes32_oracle), nil) }
  end

  describe "on create" do
    let(:contract) { EthereumContract.new adapter_type: EthereumOracle::SCHEMA_NAME }

    it "assigns an account and code template" do
      expect {
        contract.save
      }.to change {
        contract.account
      }.from(nil).and change {
        contract.template
      }.from(nil)
    end

    it "generates an Ethereum transaction" do
      expect {
        contract.save
      }.to change {
        EthereumTransaction.count
      }.by(+1)
    end
  end

  describe "on update" do
    let!(:contract) { factory_create :ethereum_contract }

    it "assigns an account and code template" do
      expect(contract.account).not_to receive(:send_transaction)

      contract.update_attributes! updated_at: 1.minute.from_now
    end
  end

  describe "#confirmed" do
    let(:address) { ethereum_address }
    let(:contract) { factory_create :ethereum_contract, owner: oracle }
    let(:oracle) { factory_create :assigned_ethereum_oracle }

    it "sets the contract's address" do
      expect {
        contract.confirmed address
      }.to change {
        contract.address
      }.from(nil).to(address)
    end

    it "informs the owner that the contract was confirmed" do
      expect(contract.owner).to receive(:contract_confirmed)
        .with(address)

      contract.confirmed address
    end

    context "when the contract uses logs" do
      before do
        allow_any_instance_of(WeiWatchersClient).to receive(:create_subscription)
          .and_return({'xid' => SecureRandom.uuid})

        contract.template.update_attributes use_logs: true
      end

      it "creates a log subscription" do
        expect {
          run_generated_jobs { contract.confirmed address }
        }.to change {
          contract.log_subscriptions.count
        }.by(+1)
      end
    end

    context "when the contract does NOT use logs" do
      before do
        allow_any_instance_of(WeiWatchersClient).to receive(:create_subscription)
          .and_return({'xid' => SecureRandom.uuid})

        contract.template.update_attributes use_logs: false
      end

      it "does NOT create a log subscription" do
        expect {
          run_generated_jobs { contract.confirmed address }
        }.not_to change {
          contract.log_subscriptions.count
        }
      end
    end
  end

  describe "#snapshot_requested" do
    let(:owner) { factory_build :ethereum_int256_oracle }
    let(:contract) { factory_build :ethereum_contract, owner: owner }
    let(:event) { factory_build :ethereum_event }

    it "passes the event logged to its owner" do
      expect(owner).to receive(:snapshot_requested)
        .with(event)

      contract.event_logged(event)
    end
  end

end
