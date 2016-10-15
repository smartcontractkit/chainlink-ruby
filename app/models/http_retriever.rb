class HttpRetriever

  def self.get(url)
    new(url).perform
  end

  def initialize(url)
    @url = url
  end

  def perform
    begin
      body = HTTParty.get(url).body
      body.force_encoding('UTF-8').gsub(/\A\xEF\xBB\xBF/, '')
    rescue
    end
  end


  private

  attr_reader :url

end
