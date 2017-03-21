FactoryGirl.define do

  factory :subtask_snapshot_request, class: Subtask::SnapshotRequest do
    subtask
    data do
      {
        value: SecureRandom.hex,
      }
    end
  end

end
