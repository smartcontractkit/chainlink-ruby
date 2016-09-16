class AssignmentScheduler

  def self.perform
    now = Time.now
    ids = AssignmentSchedule.in_progress.at(now.min, now.hour).pluck(:assignment_id)
    ids += AssignmentSchedule.in_progress.at(now.min, '*').pluck(:assignment_id)

    ids.uniq.each {|id| AssignmentScheduler.delay.check_status(id) }
  end

  def self.check_status(assignment_id)
    new(Assignment.find assignment_id).check_status
  end

  def initialize(assignment)
    @assignment = assignment
  end

  def check_status
    assignment.check_status
  end


  private

  attr_reader :assignment

end
