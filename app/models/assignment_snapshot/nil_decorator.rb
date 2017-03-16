class AssignmentSnapshot
  class NilDecorator < Decorator

    def initialize(record = nil)
      @record ||= record
    end

    def summary
      nil
    end

    def description
      nil
    end

    def description_url
      nil
    end

    def value
      nil
    end

    def details
      nil
    end

    def errors
      []
    end

    def config
      nil
    end

    def present?
      true
    end

  end
end
