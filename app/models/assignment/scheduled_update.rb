class Assignment::ScheduledUpdate < ActiveRecord::Base

  belongs_to :assignment, inverse_of: :scheduled_updates

  validates :assignment, presence: true
  validates :run_at, presence: true

end
