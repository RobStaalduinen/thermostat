FactoryBot.define do
  factory :reading do
    association             :thermostat
    number                  { 1 }
    temperature             { 22.3 }
    humidity                { 51.2 }
    battery_charge          { 99.0 }
  end
end
