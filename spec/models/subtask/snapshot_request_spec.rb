describe Subtask::SnapshotRequest do

  describe "validations" do
    it { is_expected.to have_valid(:data).when(nil, {a: 1}) }

    it { is_expected.to have_valid(:subtask).when(factory_create :subtask) }
    it { is_expected.not_to have_valid(:subtask).when(nil) }
  end

end
