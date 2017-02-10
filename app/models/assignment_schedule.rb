class AssignmentSchedule < ActiveRecord::Base

  belongs_to :assignment, inverse_of: :schedule

  validates :assignment, presence: true
  validates :hour, presence: true
  validates :minute, presence: true
  validates :day_of_month, presence: true
  validates :month_of_year, presence: true
  validates :day_of_week, presence: true
  validates :end_at, presence: true
  validates :start_at, presence: true
  validate :start_at_before_end_at

  before_validation :set_up, on: :create

  scope :in_progress, -> { joins(:assignment).where("assignments.status = ?", Assignment::IN_PROGRESS) }
  scope :at, -> (minute, hour) {
    where("minute IN (?) AND hour IN (?)",
      [minute.to_s, ('0' + minute.to_s), '*'],
      [hour.to_s, ('0' + hour.to_s), '*'])
  }

  def dayOfMonth=(dom)
    self.day_of_month = dom
  end

  def monthOfYear=(moy)
    self.month_of_year = moy
  end

  def dayOfWeek=(dow)
    self.day_of_week = dow
  end

  def startAt=(time)
    self.start_at = Time.at time.to_i
  end

  def endAt=(time)
    self.end_at = Time.at time.to_i
  end


  private

  def set_up
    self.day_of_month ||= '*'
    self.month_of_year ||= '*'
    self.day_of_week ||= '*'
    self.start_at ||= Time.now
    self.end_at ||= assignment.try(:end_at)
  end


  def start_at_before_end_at
    if end_at == Time.at(0)
      errors.add(:end_at, "must be specified")
    end

    if start_at.to_i >= end_at.to_i
      errors.add(:start_at, "must be before end at")
    end
  end

end
