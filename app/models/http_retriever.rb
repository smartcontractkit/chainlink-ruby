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
      Nokogiri::HTML(body).content
    rescue
    end
  end


  private

  attr_reader :url

end
