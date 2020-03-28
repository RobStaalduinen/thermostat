describe Reading do
  describe "Validations" do
    it { should validate_presence_of(:thermostat) }
    it { should validate_presence_of(:number) }
  end
end
