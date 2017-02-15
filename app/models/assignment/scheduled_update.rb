class Assignment::ScheduledUpdate < ActiveRecord::Base

  belongs_to :assignment, inverse_of: :scheduled_updates

  validates :assignment, presence: true
  validates :run_at, presence: true

  scope :ready, -> (time = Time.now) {
    where("scheduled = false AND run_at <= ?", time + 1.minute)
  }

end
