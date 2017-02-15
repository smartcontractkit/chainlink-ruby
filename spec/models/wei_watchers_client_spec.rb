describe WeiWatchersClient do
  let(:wei_watchers) { WeiWatchersClient.new }

  describe "#create_subscription" do
    let(:account) { ethereum_address }
    let(:wei_watchers_response) { http_response }
    let(:end_at) { Time.now }

    it "sends a post request to the WeiWatchers URL" do
      expect(WeiWatchersClient).to receive(:post)
        .with('/subscriptions', {
          body: {
            account: account,
            endAt: end_at.to_i.to_s,
          },
        })
        .and_return(wei_watchers_response)

      response = wei_watchers.create_subscription({
        account: account,
        end_at: end_at,
      })
      expect(response).to eq(JSON.parse(wei_watchers_response.body))
    end
  end

end
