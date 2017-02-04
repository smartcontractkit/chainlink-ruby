class ExternalAdapterController < ApplicationController

  before_filter :set_adapter


  private

  attr_accessor :adapter

  def authenticate_adapter
    id, password = ActionController::HttpAuthentication::Basic::user_name_and_password request

    unless @adapter = ExternalAdapter.find_by(username: id, password: password)
      render_authentication_message
    end
  end

  def authenticate_adapter_or_coordinator
    id, password = ActionController::HttpAuthentication::Basic::user_name_and_password request

    @adapter = ExternalAdapter.find_by(username: id, password: password)
    @coordinator = Coordinator.find_by(key: id, secret: password) unless adapter.present?
    unless adapter || coordinator
      render_authentication_message
    end
  end

  def set_adapter
    ensure_credentials && authenticate_adapter
  end

  def set_adapter_or_coordinator
    ensure_credentials && authenticate_adapter_or_coordinator
  end

end
