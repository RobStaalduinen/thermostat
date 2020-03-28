class Reading < ActiveRecord::Base
  belongs_to :thermostat

  validates :thermostat, presence: true
  validates :number, presence: true
end
