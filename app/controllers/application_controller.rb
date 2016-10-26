class ApplicationController < ActionController::Base

  force_ssl if: :ssl_configured?

  before_filter :set_identity, only: [:home, :identity]


  def identity
    render json: {
      bitcoin_pub: @bitcoin_pub,
      name: @name,
    }
  end


  private

  attr_reader :coordinator

  def set_identity
    @bitcoin_pub = ENV['BITCOIN_PUB_KEY']
    @name = ENV['NODE_NAME']
  end

  def render_authentication_message
    render json: {errors: ["Unauthorized."]}, status: :unauthorized
  end

  def ensure_credentials
    if ActionController::HttpAuthentication::Basic.has_basic_credentials? request
      true
    else
      render_authentication_message
      false
    end
  end

  def authenticate_coordinator
    id, password = ActionController::HttpAuthentication::Basic::user_name_and_password request

    unless @coordinator = Coordinator.find_by(key: id, secret: password)
      render_authentication_message
    end
  end

  def set_coordinator
    ensure_credentials && authenticate_coordinator
  end

  def success_response(response_params)
    render status: :ok, json: response_params
  end

  def error_response(errors)
    render status: :bad_request, json: {errors: Array.wrap(errors)}
  end

  def response_404(errors)
    render status: :not_found, json: {errors: Array.wrap(errors)}
  end

  def ssl_configured?
    Rails.env.production? || Rails.env.staging?
  end

end
