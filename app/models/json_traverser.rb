class JsonTraverser

  def self.parse(json, fields)
    begin
      hash = JsonParser.perform(json.to_s)
      new(hash).parse(fields)
    rescue JSON::ParserError => error
      Rails.logger.info "#{error}: #{json} for #{fields}"
      nil
    end
  end

  def initialize(json)
    @json = json
  end

  def parse(fields)
    value = json
    fields.each do |field|
      break if value.nil?
      value = traverse(value, field)
    end
    value
  end


  private

  attr_reader :json

  def traverse value, field
    if needs_integer?(value)
      value[field.to_i] if positive_integer?(field)
    else
      value[field]
    end
  end

  def needs_integer? object
    object.is_a?(Array) || object.is_a?(String)
  end

  def positive_integer? string
    !!(string =~ /\A+?[0-9]+\z/)
  end

end
