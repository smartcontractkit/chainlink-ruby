class CustomApiChecker

  def self.perform(expectation_id)
    expectation = CustomExpectation.find_by(id: expectation_id)
    new(expectation).perform if expectation.present?
  end

  def initialize(expectation)
    @expectation = expectation
  end

  def perform
    expectation.api_results.create({
      parsed_value: current_value,
      success: compare_to_current,
    })
  end

  def compare_to_current
    return false if current_value.nil?
    expected_value = cast(expectation.final_value, current_value)

    if expectation.comparison == '==='
      current_value == expected_value
    elsif expectation.comparison == '<'
      current_value < expected_value
    elsif expectation.comparison == '>'
      current_value > expected_value
    elsif expectation.comparison == 'contains'
      current_value.to_s.include? expectation.final_value
    else
      raise "Comparison type not found"
    end
  end


  private

  attr_reader :expectation

  def endpoint_response
    @endpoint_response ||= HttpRetriever.get(expectation.endpoint)
  end

  def current_value
    return @current_value if @current_value.present?
    return if endpoint_response.nil?
    @current_value = JsonTraverser.parse endpoint_response, expectation.fields
  end

  def cast(value, target_type)
    if target_type.is_a?(Integer) || target_type.is_a?(Float)
      value.to_f
    else
      value
    end
  end

end
