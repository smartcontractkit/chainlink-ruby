class HttpRetriever

  def self.get(url, options = {})
    new(url, options).perform
  end

  def initialize(url, options = {})
    @url = url
    @options = options
  end

  def perform
    begin
      body = HTTParty.get(url, options.compact).body
      Nokogiri::HTML(body).content
    rescue Exception => error
    end
  end


  private

  attr_reader :options, :url

end
