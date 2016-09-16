module HttpClient

  def self.included(base)
    base.include HTTParty
  end

  def self.random_id
    SecureRandom.random_number(1_000_000)
  end


  private

  def get(path, options = {})
    check_success self.class.get(path.to_s, {
      basic_auth: http_client_auth_params,
      query: options,
      headers: headers
    })
  end

  def post(path, options = {})
    check_success self.class.post(path.to_s, {
      basic_auth: http_client_auth_params,
      body: options,
      headers: headers
    })
  end

  def delete(path, options = {})
    check_success self.class.delete(path.to_s, {
      basic_auth: http_client_auth_params,
      body: options,
      headers: headers
    })
  end

  def json_get(path, options = {})
    JSON.parse get(path, options)
  end

  def json_post(path, options = {})
    JSON.parse post(path, options)
  end

  def json_delete(path, options = {})
    JSON.parse delete(path, options)
  end

  def hashie_get(path, options = {})
    hashie json_get(path, options)
  end

  def hashie_post(path, options = {})
    hashie json_post(path, options)
  end

  def hashie_delete(path, options = {})
    hashie json_delete(path, options)
  end

  def hashie(hash)
    Hashie::Mash.new hash
  end

  def headers
    {}
  end

  def http_client_auth_params
    {}
  end

  def check_success(response)
    if response.success?
      response.body
    else
      raise "Not acknowledged, try again. Errors: #{response.body}"
    end
  end

end
