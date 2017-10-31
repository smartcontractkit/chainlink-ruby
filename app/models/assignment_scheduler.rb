class AssignmentScheduler

  def self.perform
    timestamp = Time.now.to_i
    delay.queue_scheduled_snapshots timestamp
    delay.queue_recurring_snapshots timestamp
  end

  def self.queue_recurring_snapshots(timestamp)
    time = Time.at(timestamp)
    ids = AssignmentSchedule.in_progress.at(time.min, time.hour).pluck(:assignment_id)
    ids += AssignmentSchedule.in_progress.at(time.min, '*').pluck(:assignment_id)

    ids.uniq.each {|id| AssignmentScheduler.delay(priority: -1000).check_status(id) }
  end

  def self.queue_scheduled_snapshots(timestamp)
    time = Time.at(timestamp)
    ids = Assignment::ScheduledUpdate.ready(time).pluck(:id)

    ids.each do |id|
      update = Assignment::ScheduledUpdate.find(id)

      AssignmentScheduler.delay(run_at: update.run_at)
        .check_status(update.assignment_id)
      update.update_attributes scheduled: true
    end
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
