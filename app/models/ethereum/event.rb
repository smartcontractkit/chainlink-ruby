require 'ethereum'

module Ethereum
  class Event < ActiveRecord::Base

    belongs_to :log_subscription, inverse_of: :events

    validates :address, format: /\A0x[0-9a-f]{40}\z/i
    validates :block_hash, format: /\A0x[0-9a-f]{64}\z/
    validates :block_number, numericality: { greater_than_or_equal_to: 0 }
    validates :log_index, numericality: { greater_than_or_equal_to: 0 },
      uniqueness: { scope: :block_number }
    validates :log_subscription, presence: true
    validates :transaction_hash, format: /\A0x[0-9a-f]{64}\z/
    validates :transaction_index, numericality: { greater_than_or_equal_to: 0 }

    after_create :log_event_with_subscription


    private

    def log_event_with_subscription
      log_subscription.delay.log self
    end

  end
end
