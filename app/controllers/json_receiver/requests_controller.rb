class JsonReceiver::RequestsController < ApplicationController

  before_filter :ensure_receiver

  def create
    json_request = receiver.requests.build(data: request_params)

    if json_request.save
      success_response json_request.data
    else
      error_response json_request.errors.full_messages
    end
  end


  private

  attr_reader :receiver

  def ensure_receiver
    @receiver = JsonReceiver.find_by xid: params[:json_receiver_id]

    if receiver.blank?
      response_404 "JSON Receiver not found"
    end
  end

  def request_params
    params.dup.slice!(:action, :controller, :json_receiver_id)
  end

end
