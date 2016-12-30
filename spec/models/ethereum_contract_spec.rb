describe EthereumContract, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:address).when("0x#{SecureRandom.hex(20)}", nil) }
    it { is_expected.not_to have_valid(:address).when('', '0x', SecureRandom.hex(20), "0x#{SecureRandom.hex(19)}") }

    it { is_expected.to have_valid(:owner).when(factory_create(:ethereum_oracle), factory_create(:ethereum_bytes32_oracle), nil) }
  end

  describe "on create" do
    let(:contract) { EthereumContract.new }

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

    it "triggers an update for the related oracle" do
      expect(contract.owner).to receive_message_chain(:delay, :check_status)

      contract.confirmed address
    end

    it "sends instructions to the frontend" do
      expect(oracle.assignment.coordinator).to receive(:oracle_instructions)
        .with(oracle.id)

      contract.confirmed address
    end
  end

end
