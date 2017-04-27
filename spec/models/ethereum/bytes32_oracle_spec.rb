describe Ethereum::Bytes32Oracle do

  describe "validations" do
    it { is_expected.to have_valid(:address).when("0x#{SecureRandom.hex(20)}", nil) }
    it { is_expected.not_to have_valid(:address).when('', '0x', SecureRandom.hex(20), "0x#{SecureRandom.hex(19)}") }

    it { is_expected.to have_valid(:update_address).when(SecureRandom.hex(20), SecureRandom.hex(1), "0x#{SecureRandom.hex}", '0x', '', nil) }
    it { is_expected.not_to have_valid(:update_address).when('0xx', 'hi', 'function') }
  end

  describe "on create" do
    let(:assignment) { factory_create :assignment }
    let(:subtask) { factory_build :subtask, adapter: oracle, assignment: assignment }
    let(:oracle) { factory_build :ethereum_bytes32_oracle, assignment: assignment }

    context "when the address exists in the body" do
      let(:oracle) { factory_build :external_bytes32_oracle }

      it "fills in its fields from the given body" do
        expect {
          oracle.save
        }.to change {
          oracle.address
        }.from(nil).and change {
          oracle.update_address
        }.from(nil)
      end

      it "does not create an ethereum contract" do
        expect {
          oracle.save
        }.not_to change {
          oracle.ethereum_contract
        }.from(nil)
      end

      it "does save an ethereum account" do
        expect {
          oracle.save
        }.to change {
          oracle.ethereum_account
        }.from(nil).to(Ethereum::Account.default)
      end
    end

    context "when the address does not exist in the body" do
      let(:oracle) { factory_build :ethereum_bytes32_oracle, assignment: assignment }

      it "fills in its fields from the given body" do
        expect {
          oracle.save
        }.not_to change {
          oracle.address
        }
      end

      it "does create an ethereum contract" do
        expect {
          oracle.save
        }.to change {
          oracle.ethereum_contract
        }.from(nil)
      end

      it "does NOT save an ethereum account" do
        expect {
          oracle.save
        }.not_to change {
          oracle.ethereum_account
        }.from(nil)
      end

      it "does not create a write record" do
        expect(assignment).not_to receive(:check_status)

        oracle.save
      end
    end

    context "when the owner is specified in the body" do
      let(:oracle) { factory_build :ethereum_bytes32_oracle, body: hashie(owner: owner) }

      context "and the owner account is present" do
        let(:owner_account) { factory_create(:ethereum_account) }
        let(:owner) { owner_account.address }

        it "sets the account to the body's owner" do
          expect {
            oracle.save
          }.to change {
            oracle.account
          }.from(nil).to(owner_account)
        end
      end

      context "and the owner account is present" do
        let(:owner) { ethereum_address }

        it "sets the account to the default" do
          expect {
            oracle.save
          }.to change {
            oracle.account
          }.from(nil).to(Ethereum::Account.default)
        end
      end
    end

    it "sets the owner to the default" do
      expect {
        oracle.save
      }.to change {
        oracle.account
      }.from(nil).to(Ethereum::Account.default)
    end
  end

  describe "#get_status" do
    let!(:adapter) { factory_create :ethereum_bytes32_oracle }
    let(:previous_snapshot) { factory_create :adapter_snapshot, value: value }
    let(:snapshot) { factory_create :adapter_snapshot }
    let(:value) { "some string that is longer than 32 characters, because we test that it is cut down to 32" }
    let(:truncated_value) { "some string that is longer than " }
    let(:hex_truncated_value) { "736f6d6520737472696e672074686174206973206c6f6e676572207468616e20" }
    let(:assignment) { adapter.assignment }
    let(:txid) { ethereum_txid }

    it "formats the response of the oracle" do
      status = adapter.get_status(snapshot, previous_snapshot)

      expect(status.errors).to be_empty
      expect(status.fulfilled).to be true
      expect(status.description).to match /Blockchain record: 0x[0-9a-f]{64}/
      expect(status.description_url).to match /#{ENV['ETHEREUM_EXPLORER_URL']}\/tx\/0x[0-9a-f]{64}/
      expect(status.details).to eq({
        txid: EthereumOracleWrite.last.txid,
        value: truncated_value,
      })

      expect(status.value).to eq(truncated_value)
    end

    it "creates a new ethereum oracle write record" do
      expect {
        adapter.get_status(snapshot, previous_snapshot)
      }.to change {
        EthereumOracleWrite.count
      }.by(+1)

      expect(adapter.writes.last).to eq(EthereumOracleWrite.last)
    end

    it "passes the current value and its equivalent hex to the updater" do
      expect_any_instance_of(Ethereum::OracleUpdater).to receive(:perform)
        .with(hex_truncated_value, truncated_value)
        .and_return(instance_double EthereumOracleWrite, snapshot_decorator: nil)

      adapter.get_status(snapshot, previous_snapshot)
    end
  end

  describe "#ready?" do
    subject { factory_build(:ethereum_bytes32_oracle, ethereum_contract: contract).ready? }

    context "when the contract has an address" do
      let(:contract) { factory_build :ethereum_contract, address: ethereum_address }
      it { is_expected.to be true }
    end

    context "when the contract does not have an address" do
      let(:contract) { factory_build :ethereum_contract, address: nil }
      it { is_expected.to be false }
    end
  end

  describe "#contract_confirmed" do
    let(:subtask) { factory_build :subtask, adapter: nil }
    let(:oracle) { factory_create :ethereum_bytes32_oracle, subtask: subtask }

    it "calls mark ready on the subtask" do
      expect(subtask).to receive(:mark_ready)

      oracle.contract_confirmed(ethereum_address)
    end
  end

  describe "#initialization_details" do
    context "when the oracle has a contract" do
      let(:contract) { factory_create :ethereum_contract, address: ethereum_address }
      let(:oracle) do
        factory_create(:ethereum_bytes32_oracle).tap do |oracle|
          oracle.update_attributes(ethereum_contract: contract)
        end
      end

      it "pulls information from the ethereum contract and template" do
        expect(oracle.initialization_details).to eq({
          address: contract.address,
          jsonABI: contract.template.json_abi,
          readAddress: contract.template.read_address,
          solidityABI: contract.template.solidity_abi,
          writeAddress: contract.template.write_address,
        })
      end
    end

    context "when the oracle has a contract" do
      let(:oracle) { factory_create :external_bytes32_oracle }

      it "pulls information from the ethereum contract and template" do
        expect(oracle.initialization_details).to eq({
          address: oracle.address,
          writeAddress: oracle.update_address,
        })
      end
    end
  end

  describe "#request_logged" do
    let!(:subtask) { factory_create :subtask, adapter: oracle }
    let(:oracle) { factory_create :ethereum_bytes32_oracle }
    let(:event) { factory_create :ethereum_event }

    before { subtask.update_attributes ready: true }

    it "creates a new assignment snapshot" do
      expect {
        oracle.snapshot_requested event
      }.to change {
        oracle.assignment.snapshots.count
      }.by(+1)
    end

    it "assigns itself as the new snapshot's requester" do
      oracle.snapshot_requested event

      snapshot = oracle.assignment.snapshots.last
      expect(snapshot.requester).to eq(subtask)
    end

    it "saves the request parameters" do
      oracle.snapshot_requested event

      snapshot = oracle.assignment.snapshots.last
      expect(snapshot.request).to eq(event)
    end
  end
end
