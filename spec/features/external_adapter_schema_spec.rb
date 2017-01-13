describe "assignment validating its type" do
  let(:external_adapter) { factory_create :external_adapter, assignment_type: type }
  let(:adapter_assignment) { factory_build :adapter_assignment, adapter: external_adapter, parameters: data }
  let(:assignment) { factory_build :assignment, adapter_assignments: [adapter_assignment] }

  context "when validating an SEO schema" do
    let(:type) { assignment_types(:seo) }
    let(:locale) { 'us' }
    let(:max) { 20 }
    let(:min) { 1 }
    let(:phrase) { 'cheese' }
    let(:result) { 'cheese.com' }
    let(:data) do
      {
        min: min,
        max: max,
        query: {
          locale: locale,
          phrase: phrase,
        },
        result: result,
      }
    end

    context "when the data is valid" do
      it 'does not add any validation errors' do
        expect(assignment.save).to be_truthy

        expect(assignment).to be_persisted
        expect(assignment.errors).to be_empty
      end
    end

    context "when the locale is NOT valid" do
      let(:locale) { 'cheese' }

      it 'adds the validation errors to the assignment' do
        expect(assignment.save).to be_falsey

        expect(assignment.save).to be_falsey

        expect(assignment.errors.full_messages).to include "The property '#/query/locale' value \"cheese\" did not match one of the following values: us, ar, au, be, br, ca, ch, de, dk, es, fi, fr, hk, ie, il, in, it, jp, mx, nl, no, pl, ru, se, sg, tr, uk"
      end
    end

    context "when the domain name is NOT valid" do
      let(:result) { 'cheese' }

      it 'adds the validation errors to the assignment' do
        expect(assignment.save).to be_falsey

        expect(assignment.errors.full_messages).to include("The property '#/result' value \"cheese\" did not match the regex '^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\\.[a-zA-Z]{2,}$'")
      end
    end

    context "when the min or max is less than allowed" do
      let(:min) { 0 }

      it 'adds the validation errors to the assignment' do
        expect(assignment.save).to be_falsey

        expect(assignment.errors.full_messages).to include("The property '#/min' did not have a minimum value of 1, inclusively")
      end
    end

    context "when the min or max is a float" do
      let(:max) { 1.1 }

      it 'adds the validation errors to the assignment' do
        expect(assignment.save).to be_falsey

        expect(assignment.errors.full_messages).to include("The property '#/max' was not divisible by 1")
      end
    end
  end

  context "when validating a Bitcoin bond schema" do
    let(:type) { assignment_types(:payment) }
    let(:amount) { 100_000 }
    let(:recipient) { new_bitcoin_address }
    let(:data) do
      {
        amount: amount,
        recipient: recipient
      }
    end

    context "when the data is valid" do
      it 'adds the validation errors to the assignment' do
        expect(assignment.save).to be_truthy

        expect(assignment).to be_persisted
        expect(assignment.errors).to be_empty
      end
    end

    context "when the amount is too low" do
      let(:amount) { 0 }

      it 'adds the validation errors to the assignment' do
        expect(assignment.save).to be_falsey

        expect(assignment.errors.full_messages).to include "The property '#/amount' did not have a minimum value of 1, inclusively"
      end
    end

    context "when the min or max is a float" do
      let(:amount) { 1.1 }

      it 'adds the validation errors to the assignment' do
        expect(assignment.save).to be_falsey

        expect(assignment.errors.full_messages).to include("The property '#/amount' was not divisible by 1")
      end
    end
  end
end
