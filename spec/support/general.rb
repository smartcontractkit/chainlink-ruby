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

  def coordinator_log_in(coordinator = Coordinator.create)
    basic_auth_log_in coordinator.key, coordinator.secret
  end

  def input_adapter_log_in(adapter = factory_create(:input_adapter))
    basic_auth_log_in adapter.username, adapter.password
  end

  def basic_auth_log_in(username, password)
    auth = ActionController::HttpAuthentication::Basic.encode_credentials username, password
    request.env['HTTP_AUTHORIZATION'] = auth
  end

  def new_bitcoin_address
    Faker::Bitcoin.testnet_address
  end

  def http_response(options = {})
    double(:fake_http_response, {body: {}.to_json, success?: true}.merge(options))
  end

  def create_assignment_response(options = {})
    double :assignment_response, {errors: nil}.merge(options)
  end
end
