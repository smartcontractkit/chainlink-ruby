module SpecHelpers
  def factory_create(name, options = {})
    FactoryGirl.create(name, options)
  end

  def factory_build(name, options = {})
    FactoryGirl.build(name, options)
  end

  def factory_attrs(name, options = {})
    FactoryGirl.attributes_for name, options
  end

  def hashie(hash)
    Hashie::Mash.new hash
  end

  def hashie_json(text)
    hashie JSON.parse(text)
  end

  def response_json
    hashie_json response.body
  end

  def tx_from_hex(hex)
    Bitcoin::Protocol::Tx.new hex.htb
  end

  def hex_to_bin(hex)
    hex.htb
  end

  def bin_to_hex(bin)
    bin.bth
  end

  def coordinator_log_in(coordinator = factory_create(:coordinator), env = nil)
    basic_auth_log_in coordinator.key, coordinator.secret, env
  end

  def external_adapter_log_in(adapter = factory_create(:external_adapter), env = nil)
    basic_auth_log_in adapter.username, adapter.password, env
  end

  def basic_auth_log_in(username, password, env = nil)
    env ||= request.env
    auth = ActionController::HttpAuthentication::Basic.encode_credentials username, password
    env['HTTP_AUTHORIZATION'] = auth
    env
  end

  def new_bitcoin_address
    Faker::Bitcoin.testnet_address
  end

  def http_response(options = {})
    double(:fake_http_response, {body: {}.to_json, success?: true}.merge(options))
  end

  def acknowledged_response(options = {})
    http_response body: {acknowledged_at: Time.now.to_i}.to_json
  end

  def create_assignment_response(options = {})
    double :assignment_response, {errors: nil}.merge(options)
  end

  def port_open?(ip, port, seconds=1)
    Timeout::timeout(seconds) do
        begin
          TCPSocket.new(ip, port).close
          true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          false
        end
      end
    rescue Timeout::Error
      false
  end

  def port_closed?(ip, port, seconds=1)
    !port_open? ip, port, seconds
  end

end
