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
end
