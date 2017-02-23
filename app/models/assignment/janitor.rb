class Assignment::Janitor

  def self.schedule_clean_up
    delay.clean_up
  end

  def self.clean_up
    Assignment.expired.termless.pluck(:id).each do |assignment_id|
      delay.perform assignment_id
    end
  end

  def perform(assignment_id)
    assignment = Assignment.find(assignment_id)

    new(assignment).perform
  end

  def initialize(assignment)
    @assignment = assignment
  end

  def perform
    assignment.close_out! if assignment.expired?
  end


  private

  attr_reader :assignment

end
