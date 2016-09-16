describe InputAdapter, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:assignment_type).when(factory_create(:assignment_type)) }
    it { is_expected.not_to have_valid(:assignment_type).when(nil) }

    it { is_expected.to have_valid(:url).when(Faker::Internet.domain_name) }
    it { is_expected.not_to have_valid(:url).when('', nil) }
  end

  describe "on create" do
    let(:adapter) { factory_build :input_adapter }

    it "assigns username and password for authentication" do
      expect {
        adapter.save
      }.to change {
        adapter.username
      }.from(nil).and change {
        adapter.password
      }.from(nil)
    end
  end

  describe ".for_type" do
    let!(:adapter1) { factory_create :input_adapter }
    let!(:adapter2) { factory_create :input_adapter }
    let!(:adapter3) { factory_create :input_adapter }

    it "returns the adapter matching that type" do
      expect(InputAdapter.for_type adapter1.type).to eq(adapter1)
      expect(InputAdapter.for_type adapter2.type).to eq(adapter2)
      expect(InputAdapter.for_type adapter3.type).to eq(adapter3)

      expect(InputAdapter.for_type (adapter3.type + '1')).to be_nil
    end
  end

end
