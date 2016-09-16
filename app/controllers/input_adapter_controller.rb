class InputAdapterController < ApplicationController

  before_filter :set_adapter


  private

  attr_accessor :adapter

  def authenticate_adapter
    id, password = ActionController::HttpAuthentication::Basic::user_name_and_password request

    unless @adapter = InputAdapter.find_by(username: id, password: password)
      render_authentication_message
    end
  end

  def set_adapter
    ensure_credentials && authenticate_adapter
  end

end
