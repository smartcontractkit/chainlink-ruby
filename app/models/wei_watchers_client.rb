class WeiWatchersClient

  include HttpClient
  base_uri ENV['WEI_WATCHERS_URL']

  def create_subscription(options = {})
    hashie_post('/subscriptions', {
      account: options[:account],
      endAt: (options[:endAt] || options[:end_at]).to_i.to_s,
      topics: options[:topics],
    }.compact)
  end


  private

  def http_client_auth_params
    {
      password: ENV['WEI_WATCHERS_PASSWORD'],
      username: ENV['WEI_WATCHERS_USERNAME'],
    }
  end

end
