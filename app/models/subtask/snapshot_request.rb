class Subtask::SnapshotRequest < ActiveRecord::Base

  belongs_to :subtask

  validates :subtask, presence: true


  def data=(params)
    self.data_json = (params ? params.to_json : nil)
    data
  end

  def data
    JSON.parse(data_json) if data_json.present?
  end

end
