describe Ethereum::FormattedOracle do

  describe "validations" do
    it { is_expected.to have_valid(:address).when("0x#{SecureRandom.hex(20)}") }
    it { is_expected.not_to have_valid(:address).when('', nil, '0x', SecureRandom.hex(20), "0x#{SecureRandom.hex(19)}") }

    it { is_expected.to have_valid(:update_address).when('0x', nil, "0x#{SecureRandom.hex(1)}", "0x#{SecureRandom.hex(20)}") }
    it { is_expected.not_to have_valid(:update_address).when('0xx', 'hi', 'function') }
  end

  describe "on create" do
    let(:oracle) { factory_build :ethereum_formatted_oracle }

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

    it "uses the default ethereum account" do
      expect {
        oracle.save
      }.to change {
        oracle.ethereum_account
      }.from(nil).to(Ethereum::Account.default)
    end

    context "when the owner is specified in the body" do
      let(:oracle) { factory_build :ethereum_formatted_oracle, body: hashie(owner: owner) }

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
  end


  describe "#get_status" do
    let!(:subtask) { factory_create(:subtask, adapter: adapter, parameters: {value: subtask_value}) }
    let(:adapter) { factory_create :ethereum_formatted_oracle }
    let(:snapshot) { factory_create :adapter_snapshot }
    let(:value) { '12431235452456' }
    let(:subtask_value) { '6543214321' }
    let(:previous_snapshot) { factory_create :adapter_snapshot, value: value }

    it "passes the current value and its equivalent hex to the updater" do
      expect_any_instance_of(Ethereum::OracleUpdater).to receive(:perform)
        .with(value, value)
        .and_return(instance_double EthereumOracleWrite, snapshot_decorator: nil)

      adapter.get_status(snapshot, previous_snapshot)
    end

    context "when no previous snapshot is passed in" do
      it "reads the value from the subtask paramters" do
        expect_any_instance_of(Ethereum::OracleUpdater).to receive(:perform)
          .with(subtask_value, subtask_value)
          .and_return(instance_double EthereumOracleWrite, snapshot_decorator: nil)

        adapter.get_status(snapshot)
      end
    end
  end

  describe "#ready?" do
    subject { factory_build(:ethereum_formatted_oracle).ready? }

    it { is_expected.to be true }
  end

  describe "#initialization_details" do
    let(:oracle) { factory_create :ethereum_formatted_oracle }

    it "pulls information from the ethereum contract and template" do
      expect(oracle.initialization_details).to eq({
        address: oracle.address,
        writeAddress: oracle.update_address,
      })
    end
  end
end
