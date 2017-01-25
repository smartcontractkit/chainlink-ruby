describe SchemaValidator, type: :model do
  describe "#validate" do
    let(:validator) { SchemaValidator.new schema }
    let(:schema) do
      {
        "type" => "object",
        "required" => ["foo"],
        "properties" => {
          "foo" => {"type" => "integer"}
        }
      }
    end

    context "when the blob is NOT valid" do
      let(:data) { { foo: 'bar' } }

      it "returns false if the hash is not valid" do
        expect(validator.validate data).to be_falsey
      end

      it "saves the errors when the validation fails" do
        validator.validate data

        expect(validator.errors).to include("The property '#/foo' of type String did not match the following type: integer")
      end
    end

    context "when the blob is valid" do
      let(:data) { { foo: 2 } }

      it "returns true" do
        expect(validator.validate data).to be_truthy
      end

      it "saves the errors when the validation fails" do
        validator.validate data

        expect(validator.errors).to be_empty
      end
    end
  end

  describe ".version" do
    let(:validator) { instance_double SchemaValidator }

    context "when the version is 0.1.0" do
      let(:version) { "0.1.0" }

      it "returns a validator with the 0.1.0 schema" do
        expect(SchemaValidator).to receive(:new)
          .with(File.read 'lib/assets/schemas/assignment_v0_1_0.json')
          .and_return(validator)

        expect(SchemaValidator.version version).to eq(validator)
      end
    end

    context "when the version is 1.0.0" do
      let(:version) { "1.0.0" }

      it "returns a validator with the 1.0.0 schema" do
        expect(SchemaValidator).to receive(:new)
          .with(File.read 'lib/assets/schemas/assignment_v1_0_0.json')
          .and_return(validator)

        expect(SchemaValidator.version version).to eq(validator)
      end

      context "when the version is not in the list" do
        let(:version) { "1.0.1" }

        it "returns nil" do
          expect(SchemaValidator.version version).to eq(nil)
        end
      end
    end
  end
end
