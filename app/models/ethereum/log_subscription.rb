require 'ethereum'

module Ethereum
  class LogSubscription < ActiveRecord::Base

    belongs_to :owner, polymorphic: true
    has_many :events, inverse_of: :log_subscription

    validates :account, presence: true
    validates :end_at, presence: true
    validates :owner, presence: true
    validates :xid, presence: true

    before_validation :set_up, on: :create


    private

    def set_up
      response = wei_watchers.create_subscription({
        account: account,
        end_at: end_at,
      })

      self.xid = response['xid']
    end

    def wei_watchers
      @wei_watchers ||= WeiWatchersClient.new
    end

  end
end
