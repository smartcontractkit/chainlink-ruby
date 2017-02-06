describe AdapterBuilder do

  describe ".perform" do
    subject { AdapterBuilder.perform type, params }

    let(:params) { {not: 'tested'} }

    context "when building an Ethereum oracle" do
      let(:type) { EthereumOracle::SCHEMA_NAME }

      it { is_expected.to be_a EthereumOracle }
      it { is_expected.to be_new_record }
    end

    context "when building an adapter of type 'oracle'" do
      let(:type) { 'oracle' }

      it { is_expected.to be_a EthereumOracle }
      it { is_expected.to be_new_record }
    end

    context "when building a bytes32 oracle" do
      let(:type) { Ethereum::Bytes32Oracle::SCHEMA_NAME }

      it { is_expected.to be_a Ethereum::Bytes32Oracle }
      it { is_expected.to be_new_record }
    end

    context "when building a uint256 oracle" do
      let(:type) { Ethereum::Uint256Oracle::SCHEMA_NAME }

      it { is_expected.to be_a Ethereum::Uint256Oracle }
      it { is_expected.to be_new_record }
    end

    context "when building a JSON adapter" do
      let(:type) { JsonAdapter::SCHEMA_NAME }

      it { is_expected.to be_a JsonAdapter }
      it { is_expected.to be_new_record }
    end

    context "when building a bitcoin comparison oracle" do
      let(:type) { CustomExpectation::SCHEMA_NAME }

      it { is_expected.to be_a CustomExpectation }
      it { is_expected.to be_new_record }
    end

    context "when building an adapter of type 'custom'" do
      let(:type) { 'custom' }

      it { is_expected.to be_a CustomExpectation }
      it { is_expected.to be_new_record }
    end

    context "when it is a type of external adapter" do
      let(:adapter) { ExternalAdapter.first }
      let(:type) { adapter.type }

      it { is_expected.to be_a ExternalAdapter }
      it { is_expected.to be_persisted }
      it { is_expected.to eq adapter }
    end

    context "when the type cannot be found" do
      let(:type) { 'blah!' }
      it "raises an error" do
        expect {
          subject
        }.to raise_error 'No adapter type found for "blah!"'
      end
    end
  end

end
