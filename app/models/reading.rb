class Reading < ActiveRecord::Base
  DATA_ATTRIBUTES = %w(number temperature humidity battery_charge)
  belongs_to :thermostat

  def data
    self.attributes.slice(*DATA_ATTRIBUTES)
  end

  validates :thermostat, presence: true
  validates :number, presence: true
end
