class HttpRetriever

  def self.get(url)
    new(url).perform
  end

  def initialize(url)
    @url = url
  end

  def perform
    begin
      HTTParty.get(url).body
    rescue
    end
  end


  private

  attr_reader :url

end
