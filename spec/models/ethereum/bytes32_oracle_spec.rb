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

      it "does create a write record" do
        expect_any_instance_of(Assignment).to receive(:check_status) do |receiver|
          expect(receiver).to eq(assignment)
        end

        subtask.save # saves the oracle indirectly
        Delayed::Job.last.invoke_job
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
  end

  describe "#get_status" do
    let!(:adapter) { factory_create :ethereum_bytes32_oracle }
    let(:subtask) { factory_create :subtask, adapter: adapter }
    let(:snapshot) { factory_create :adapter_snapshot, subtask: subtask }
    let(:value) { "some string that is longer than 32 characters, because we test that it is cut down to 32" }
    let(:truncated_value) { value[0..31] }
    let(:params) { {value: value} }
    let(:assignment) { adapter.assignment }
    let(:txid) { ethereum_txid }

    it "formats the response of the oracle" do
      status = adapter.get_status(snapshot, params)

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
        adapter.get_status(snapshot, params)
      }.to change {
        EthereumOracleWrite.count
      }.by(+1)

      expect(adapter.writes.last).to eq(EthereumOracleWrite.last)
    end
  end

end
