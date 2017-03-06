require 'ethereum'

class Ethereum::LogWatcher < ActiveRecord::Base
  SCHEMA_NAME = 'ethereumLogWatcher'

  include AdapterBase

  validates :address, format: /\A0x[0-9a-f]{40}\z/i

  before_validation :set_up_from_body, on: :create


  private

  def set_up_from_body
    if body.present?
      self.address = body['address']
    end
  end

end
