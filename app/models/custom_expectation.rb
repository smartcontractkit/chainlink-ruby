class CustomExpectation < ActiveRecord::Base
  SCHEMA_NAME = 'bitcoinComparisonJSON'
  URL_REGEXP = File.read 'lib/assets/custom_uri_regexp.txt'

  include AdapterBase

  has_one :subtask, as: :adapter
  has_one :assignment, through: :subtask
  has_one :term, as: :expectation, inverse_of: :expectation
  has_many :api_results, inverse_of: :custom_expectation

  validates :comparison, inclusion: { in: ['===', '<', '>', 'contains'] }
  validates :endpoint, format: { with: /\A#{URL_REGEXP}\z/x }
  validates :field_list, presence: true
  validates :final_value, presence: true

  before_validation :set_up_from_body, on: :create
  after_create :check_api


  def assignment
    subtask.try(:assignment) || super
  end

  def check_rankings
    if completed_rankings.any?
      related_term.update_status Term::COMPLETED
    end
  end

  def fields=(fields)
    self.field_list = Array.wrap(fields).to_json
    self.fields
  end

  def fields
    return [] if field_list.blank?
    JSON.parse(field_list)
  end

  def mark_completed!
    if api_results.any?(&:success?)
      related_term.update_status Term::COMPLETED
    end
  end

  def assignment_type
    'custom'
  end

  def related_term
    term || assignment.term
  end

  def get_status(assignment_snapshot, _details = {})
    updater.perform.snapshot_decorator
  end

  def schema_errors_for(parameters)
    []
  end


  private

  attr_reader :body

  def set_up_from_body
    return unless body.present?

    self.comparison = body['comparison']
    self.endpoint = body['endpoint']
    self.fields = body['fields']
    self.final_value = body['value']
  end

  def check_api
    delay.check_status
  end

  def updater
    CustomApiChecker.new(self)
  end

end
