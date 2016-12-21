class AdapterAssignment < ActiveRecord::Base

  belongs_to :adapter, polymorphic: true
  belongs_to :assignment, inverse_of: :adapter_assignments
  has_many :adapter_snapshots

  validates :adapter, presence: true
  validates :assignment, presence: true
  validates :index, uniqueness: { scope: [:assignment] },
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :start_tracking, on: :create


  def parameters
    JSON.parse(adapter_params_json) if adapter_params_json.present?
  end

  def parameters=(params)
    self.adapter_params_json = params ? params.to_json : nil
    parameters
  end


  private

  def start_tracking
    return if assignment.blank? || adapter.blank?
    response = adapter.start assignment

    if response.errors.present?
      response.errors.each do |error_message|
        errors.add(:base, "Adapter: #{error_message}")
      end
    end
  end

end
