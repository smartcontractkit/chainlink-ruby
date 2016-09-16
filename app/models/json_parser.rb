class JsonParser

  def self.perform(body)
    new(body).parse
  end

  def initialize(body)
    @body = body
  end

  def parse
    JSON.parse(body, allow_nan: true)
  end


  private

  attr_reader :body

end
