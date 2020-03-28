class Thermostat < ActiveRecord::Base
  has_many :readings

  validates :household_token, presence: true
end
