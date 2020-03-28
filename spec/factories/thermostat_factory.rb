FactoryBot.define do
  factory :thermostat do
    household_token         { 'abc123' }
    location                { '123 Fake St.' }
  end
end
