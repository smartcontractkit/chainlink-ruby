describe Ethereum::Int256Oracle do

  describe "validations" do
    it { is_expected.to have_valid(:address).when("0x#{SecureRandom.hex(20)}", nil) }
    it { is_expected.not_to have_valid(:address).when('', '0x', SecureRandom.hex(20), "0x#{SecureRandom.hex(19)}") }

    it { is_expected.to have_valid(:update_address).when(SecureRandom.hex(20), SecureRandom.hex(1), "0x#{SecureRandom.hex}", '0x', '', nil) }
    it { is_expected.not_to have_valid(:update_address).when('0xx', 'hi', 'function') }
  end

  describe "on create" do
    let(:oracle) { factory_build :external_int256_oracle }

    context "when the address exists in the body" do
      let(:oracle) { factory_build :external_int256_oracle }

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
      let(:assignment) { factory_create :assignment }
      let(:subtask) { factory_build :subtask, adapter: oracle, assignment: assignment }
      let(:oracle) { factory_build :ethereum_int256_oracle, assignment: assignment }

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

    it "sets the result multiplier to 1 by default" do
      expect {
        oracle.save
      }.to change {
        oracle.result_multiplier
      }.from(nil).to(1)
    end
  end


  describe "#get_status" do
    let!(:adapter) { factory_create :ethereum_int256_oracle }
    let(:snapshot) { factory_create :adapter_snapshot }
    let(:value) { 12431235452456 }
    let(:hex_truncated_value) { "00000000000000000000000000000000000000000000000000000b4e5f5f8e28" }
    let(:previous_snapshot) { factory_create :adapter_snapshot, value: value }

    it "passes the current value and its equivalent hex to the updater" do
      expect_any_instance_of(Ethereum::OracleUpdater).to receive(:perform)
        .with(hex_truncated_value, value)
        .and_return(instance_double EthereumOracleWrite, snapshot_decorator: nil)

      adapter.get_status(snapshot, previous_snapshot)
    end

    context "when the contract has a result multiplier" do
      let(:value) { 124312354524.56 }
      let(:value_multiplied) { 12431235452456 }
      let(:hex_truncated_value) { "00000000000000000000000000000000000000000000000000000b4e5f5f8e28" }
      let!(:adapter) { factory_create :ethereum_int256_oracle, result_multiplier: 100 }

      it "passes the current value and its equivalent hex to the updater" do
        expect_any_instance_of(Ethereum::OracleUpdater).to receive(:perform)
          .with(hex_truncated_value, value_multiplied)
          .and_return(instance_double EthereumOracleWrite, snapshot_decorator: nil)

        adapter.get_status(snapshot, previous_snapshot)
      end
    end
  end

  describe "#ready?" do
    subject { factory_build(:ethereum_int256_oracle, ethereum_contract: contract).ready? }

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
    let(:oracle) { factory_create :ethereum_int256_oracle, subtask: subtask }

    it "calls mark ready on the subtask" do
      expect(subtask).to receive(:mark_ready)

      oracle.contract_confirmed(ethereum_address)
    end
  end

  describe "#initialization_details" do
    context "when the oracle has a contract" do
      let(:contract) { factory_create :ethereum_contract, address: ethereum_address }
      let(:oracle) do
        factory_create(:ethereum_int256_oracle).tap do |oracle|
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
      let(:oracle) { factory_create :external_int256_oracle }

      it "pulls information from the ethereum contract and template" do
        expect(oracle.initialization_details).to eq({
          address: oracle.address,
          writeAddress: oracle.update_address,
        })
      end
    end
  end
end
