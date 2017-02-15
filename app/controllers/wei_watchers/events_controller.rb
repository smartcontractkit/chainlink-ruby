class WeiWatchers::EventsController < ApplicationController

  before_filter :ensure_subscription

  def create
    event = subscription.events.build(event_params)

    if event.save
      success_response subscription: subscription_xid
    else
      error_response event.errors.full_messages
    end
  end


  private

  attr_reader :subscription

  def ensure_subscription
    unless @subscription = Ethereum::LogSubscription.find_by(xid: subscription_xid)
      error_response "Subscription not found."
    end
  end

  def event_params
    {
      address: params[:address],
      block_hash: params[:blockHash],
      block_number: params[:blockNumber],
      data: params[:data],
      log_index: params[:logIndex],
      transaction_hash: params[:transactionHash],
      transaction_index: params[:transactionIndex],
    }
  end

  def subscription_xid
    @subscription_xid ||= params[:subscription] || params[:subscriptionXID]
  end

end
