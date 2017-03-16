class JsonReceiverRequest < ActiveRecord::Base

  belongs_to :json_receiver, inverse_of: :requests

  validates :json_receiver, presence: true

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
    json_receiver.delay.snapshot_requested self
  end

end
