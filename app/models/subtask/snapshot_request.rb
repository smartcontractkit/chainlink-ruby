class Subtask::SnapshotRequest < ActiveRecord::Base

  belongs_to :subtask

  validates :subtask, presence: true

  after_create :request_snapshot


  def data=(params)
    self.data_json = (params ? params.to_json : nil)
    data
  end

  def data
    JSON.parse(data_json) if data_json.present?
  end


  private

  def request_snapshot
    subtask.delay.snapshot_requested self
  end

end
