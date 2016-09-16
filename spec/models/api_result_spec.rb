describe ApiResult, type: :model do
  describe "validations" do
    it { is_expected.to have_valid(:custom_expectation).when(factory_create(:custom_expectation)) }
    it { is_expected.not_to have_valid(:custom_expectation).when(nil) }

    it { is_expected.to have_valid(:parsed_value).when(nil, '', {}.to_json, SecureRandom.hex) }
  end

  describe "on create" do
    let(:result) { ApiResult.new success: successful, custom_expectation: expectation }
    let(:expectation) { factory_create :custom_expectation }

    context "when the marked successful" do
      let(:successful) { true }

      it "marks the expectation as successful" do
        expect(expectation).to receive(:mark_completed!)

        result.save
      end
    end

    context "when the marked unsuccessful" do
      let(:successful) { false }

      it "does not mark the expectation as successful" do
        expect(expectation).not_to receive(:mark_completed!)

        result.save
      end
    end
  end
end
