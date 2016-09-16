class AssignmentSnapshot
  class ApiResultDecorator < Decorator

    def summary
      return if assignment.blank?
      if value.present?
        "#{assignment.name} received value \"#{value}\"."
      else
        "#{assignment.name} parsed a null value."
      end
    end

    def details
      {value: value}
    end

    def value
      record.parsed_value
    end


    private

    def assignment
      record.assignment
    end

  end
end
