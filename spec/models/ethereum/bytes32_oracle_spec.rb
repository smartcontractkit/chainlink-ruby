describe Ethereum::Bytes32Oracle do

  describe "validations" do
    it { is_expected.to have_valid(:address).when("0x#{SecureRandom.hex(20)}", nil) }
    it { is_expected.not_to have_valid(:address).when('', '0x', SecureRandom.hex(20), "0x#{SecureRandom.hex(19)}") }

    it { is_expected.to have_valid(:update_address).when(SecureRandom.hex(20), SecureRandom.hex(1), "0x#{SecureRandom.hex}", '0x', '', nil) }
    it { is_expected.not_to have_valid(:update_address).when('0xx', 'hi', 'function') }
  end

  describe "on create" do
    context "when the address exists in the body" do
      let(:oracle) { factory_build(:ethereum_bytes32_oracle) }

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
    end

    context "when the address does not exist in the body" do
      let(:oracle) { Ethereum::Bytes32Oracle.new }

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
    end
  end

end
