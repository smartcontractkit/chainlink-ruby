class Subtask::SnapshotRequest < ActiveRecord::Base

  belongs_to :subtask, inverse_of: :snapshot_requests

  validates :subtask, presence: true

  after_create :request_snapshot


  def data=(params)
    self.data_json = (params ? params.to_json : nil)
    data
  end

  def data
    JSON.parse(data_json) if data_json.present?
  end

  def value
    data['value']
  end

  def summary
    data['summary']
  end

  def description
    data['description']
  end

  def description_url
    data['description_url']
  end

  def details
    data['details']
  end

  def status
    data['status']
  end

  def config
    subtask.parameters
  end

  def fulfilled
    true
  end


  private

  def request_snapshot
    subtask.delay.snapshot_requested self
  end

end
