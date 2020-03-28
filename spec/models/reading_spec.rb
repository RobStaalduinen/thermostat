describe Reading do

  describe "Instance methods" do
    let!(:reading) { create(:reading) }
    describe "data" do
      it "returns number, temperature, humidity and battery_charge" do
        data = reading.data
        expect(data['number']).to eq(reading.number)
        expect(data['temperature']).to eq(reading.temperature)
        expect(data['humidity']).to eq(reading.humidity)
        expect(data['battery_charge']).to eq(reading.battery_charge)
      end
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:thermostat) }
    it { should validate_presence_of(:number) }
  end
end
