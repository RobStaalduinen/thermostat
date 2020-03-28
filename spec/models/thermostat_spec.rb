describe Thermostat do
  describe "Validations" do
    it { should validate_presence_of(:household_token) }
  end
end
