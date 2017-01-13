module AdapterBase

  attr_accessor :body

  def coordinator
    assignment.coordinator
  end

  def related_term
    assignment.term
  end

  def check_status
    assignment.check_status
  end

  def start(_assignment = nil)
    # see Assignment#start_tracking
    Hashie::Mash.new errors: self.tap(&:valid?).errors.full_messages
  end

  def stop(_assignment)
    # see Assignment#close_out!
  end

  def close_out!
    # see Term#update_status
  end

  def get_status(assignment_snapshot, params = {})
    raise "Adapter#get_status must be defined by the adapter class."
  end

  def type_name
    SCHEMA_NAME
  end

  def schema_errors_for(parameters)
    []
  end

end
