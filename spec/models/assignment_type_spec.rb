describe AssignmentType, type: :model do

  describe "validations" do
    let(:older) { AssignmentType.create name: 'blah', json_schema: {SecureRandom.base64 => SecureRandom.base64}.to_json }

    it { is_expected.to have_valid(:description).when(nil, '', 'blah', older.description) }

    it { is_expected.to have_valid(:json_schema).when({}.to_json, older.json_schema) }
    it { is_expected.not_to have_valid(:json_schema).when(nil, '', SecureRandom.hex) }

    it { is_expected.to have_valid(:name).when(SecureRandom.base64) }
    it { is_expected.not_to have_valid(:name).when(nil, '', older.name) }
  end

end
