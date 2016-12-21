class AdapterAssignment < ActiveRecord::Base

  belongs_to :adapter, polymorphic: true
  belongs_to :assignment

  validates :adapter, presence: true
  validates :assignment, presence: true
  validates :index, uniqueness: { scope: [:assignment] },
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def adapter_params
    JSON.parse(adapter_params_json) if adapter_params_json.present?
  end

  def adapter_params=(params)
    self.adapter_params_json = params ? params.to_json : nil
    adapter_params
  end

end
