require 'ethereum'

class Ethereum::LogWatcher < ActiveRecord::Base
  SCHEMA_NAME = 'ethereumLogWatcher'

  include AdapterBase

  has_one :subtask, as: :adapter
  has_one :assignment, through: :subtask
  has_many :log_subscriptions, as: :owner

  validates :address, format: /\A0x[0-9a-f]{40}\z/i

  before_validation :set_up_from_body, on: :create
  after_create :delay_subscribe_to_notifications

  def event_logged(event)
    assignment.check_status({
      request: event,
      requester: subtask,
    })
  end


  private

  def set_up_from_body
    if body.present?
      self.address = body['address']
    end
  end

  def delay_subscribe_to_notifications
    delay.subscribe_to_notifications
  end

  def subscribe_to_notifications
    log_subscriptions.create({
      account: address,
      end_at: end_at
    })
  end

end
