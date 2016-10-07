describe CustomApiChecker, type: :model do
  describe "#perform" do
    let(:checker) { CustomApiChecker.new(expectation) }
    let(:term) { factory_build :term }
    let(:expectation) { factory_create :custom_expectation, comparison: '===', term: term }
    let(:response) { {a: SecureRandom.hex}.to_json }

    before do
      expect(HttpRetriever).to receive(:get)
        .with(expectation.endpoint)
        .and_return(response)

      expect(JsonTraverser).to receive(:parse)
        .with(response, expectation.fields)
        .and_return(response_value)
    end

    context "when the values do match" do
      let(:response_value) { expectation.final_value }

      it "creates a new successful API result" do
        expect {
          checker.perform
        }.to change {
          expectation.reload.api_results.count
        }.by(+1)

        expect(ApiResult.last).to be_success
      end

      it "marks the expectation's term completed" do
        expect {
          checker.perform
        }.to change {
          expectation.related_term.reload.status
        }.to(Term::COMPLETED)
      end
    end

    context "when the values do NOT match" do
      let(:response_value) { expectation.final_value + '!' }

      it "creates a new unsuccessful API result" do
        expect {
          checker.perform
        }.to change {
          expectation.reload.api_results.count
        }.by(+1)

        expect(ApiResult.last).not_to be_success
      end

      it "does not change the term's status" do
        expect {
          checker.perform
        }.not_to change {
          expectation.related_term.reload.status
        }
      end
    end
  end

  describe "#compare_to_current" do
    subject { checker.compare_to_current }

    let(:expectation) { factory_create :custom_expectation }
    let(:checker) { CustomApiChecker.new(expectation) }
    let(:response_value) { "one hundred thousand" }
    let(:response) { {a: SecureRandom.hex}.to_json }
    let(:base_value) { Random.rand(1_000.0) }
    let(:final_value) { base_value.to_s }

    before do
      expectation.update_attributes!({
        comparison: comparison_type,
        final_value: final_value
      })

      expect(HttpRetriever).to receive(:get)
        .with(expectation.endpoint)
        .and_return(response)

      expect(JsonTraverser).to receive(:parse)
        .with(response, expectation.fields)
        .and_return(response_value)
    end

    context "when the comparison is '==='" do
      let(:comparison_type) { '===' }

      context "and the response is equal" do
        let(:response_value) { final_value }
        it { is_expected.to be_truthy }
      end

      context "and the response is not equal" do
        let(:response_value) { final_value + '!' }
        it { is_expected.to be_falsey }
      end

      context "and the response is the integer equivalent" do
        let(:response_value) { final_value.to_i }
        it { is_expected.to be_falsey }
      end

      context "and the response is a real number floating point" do
        let(:final_value) { base_value.to_i }
        let(:response_value) { final_value.to_f }
        it { is_expected.to be_truthy }
      end

      context "and the response is an integer equivalent" do
        let(:final_value) { base_value.to_i.to_s }
        let(:response_value) { final_value.to_i }
        it { is_expected.to be_truthy }
      end

      context "and the response is the floating point equivalent" do
        let(:response_value) { final_value.to_f }
        it { is_expected.to be_truthy }
      end

      context "and the response is false" do
        let(:response_value) { nil }
        it { is_expected.to be_falsey }
      end
    end

    context "when the comparison is '>'" do
      let(:comparison_type) { '>' }

      context "and the response is equal" do
        let(:response_value) { final_value }
        it { is_expected.to be_falsey }
      end

      context "and the response is longer" do
        let(:response_value) { final_value + '!' }
        it { is_expected.to be_truthy }
      end

      context "and the response is shorter" do
        let(:response_value) { final_value[0...-1] }
        it { is_expected.to be_falsey }
      end

      context "and the response is the integer equivalent" do
        let(:response_value) { final_value.to_i }
        it { is_expected.to be_falsey }
      end

      context "and the response is a real number floating point" do
        let(:final_value) { base_value.to_i }
        let(:response_value) { final_value.to_f }
        it { is_expected.to be_falsey }
      end

      context "and the response is an integer equivalent" do
        let(:final_value) { base_value.to_i.to_s }
        let(:response_value) { final_value.to_i }
        it { is_expected.to be_falsey }
      end

      context "and the response is the floating point equivalent" do
        let(:response_value) { final_value.to_f }
        it { is_expected.to be_falsey }
      end

      context "and the response is false" do
        let(:response_value) { nil }
        it { is_expected.to be_falsey }
      end
    end

    context "when the comparison is '<'" do
      let(:comparison_type) { '<' }

      context "and the response is equal" do
        let(:response_value) { final_value }
        it { is_expected.to be_falsey }
      end

      context "and the response is longer" do
        let(:response_value) { final_value + '!' }
        it { is_expected.to be_falsey }
      end

      context "and the response is shorter" do
        let(:response_value) { final_value[0...-1] }
        it { is_expected.to be_truthy }
      end

      context "and the response is the integer equivalent" do
        # assumes that test data is not a perfectly round float
        let(:response_value) { final_value.to_i }
        it { is_expected.to be_truthy }
      end

      context "and the response is a real number floating point" do
        let(:final_value) { base_value.to_i }
        let(:response_value) { final_value.to_f }
        it { is_expected.to be_falsey }
      end

      context "and the response is an integer equivalent" do
        let(:final_value) { base_value.to_i.to_s }
        let(:response_value) { final_value.to_i }
        it { is_expected.to be_falsey }
      end

      context "and the response is the floating point equivalent" do
        let(:response_value) { final_value.to_f }
        it { is_expected.to be_falsey }
      end

      context "and the response is false" do
        let(:response_value) { nil }
        it { is_expected.to be_falsey }
      end
    end

    context "when the comparison is 'contains'" do
      let(:comparison_type) { 'contains' }

      context "and the response is equal" do
        let(:response_value) { final_value }
        it { is_expected.to be_truthy }
      end

      context "and the response is longer" do
        let(:response_value) { final_value + '!' }
        it { is_expected.to be_truthy }
      end

      context "and the response is shorter" do
        let(:response_value) { final_value[0...-1] }
        it { is_expected.to be_falsey }
      end

      context "and the response is the integer equivalent" do
        let(:final_value) { 4.321.to_s }
        let(:response_value) { 4 }
        it { is_expected.to be_falsey }
      end

      context "and the response is a real number floating point" do
        let(:final_value) { base_value.to_i }
        let(:response_value) { final_value.to_f }
        it { is_expected.to be_truthy }
      end

      context "and the response is an integer equivalent" do
        let(:final_value) { base_value.to_i.to_s }
        let(:response_value) { final_value.to_i }
        it { is_expected.to be_truthy }
      end

      context "and the response is the floating point equivalent" do
        let(:final_value) { 4.321.to_s }
        let(:response_value) { final_value.to_f }
        it { is_expected.to be_truthy }
      end

      context "and the response is false" do
        let(:response_value) { nil }
        it { is_expected.to be_falsey }
      end
    end
  end
end
