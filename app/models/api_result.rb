class ApiResult < ActiveRecord::Base

  belongs_to :custom_expectation, inverse_of: :api_results
  has_one :assignment, through: :custom_expectation

  validates :custom_expectation, presence: true

  after_create :mark_expectation_completed, if: :success?

  def snapshot_decorator
    AssignmentSnapshot::ApiResultDecorator.new self
  end


  private

  def mark_expectation_completed
    custom_expectation.mark_completed!
  end

end
