describe ThermostatReadingService do
  let!(:thermostat) { create(:thermostat) }
  let!(:service) { ThermostatReadingService.new(thermostat) }

  describe "find_by_number" do
    context "with no matching reading" do
      it "raises NotFound error" do
        expect{
        service.find_by_number(12345)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with matching reading in database" do
      let!(:reading) { create(:reading, thermostat: thermostat) }

      it "returns data hash" do
        returned_reading = service.find_by_number(reading.number)
        expect(returned_reading).to eq(reading.data)
      end
    end

    context "with matching reading in cache" do
      before do
        service.create_async({temperature: 10, humidity: 10, battery_charge: 10})
      end

      it "returns data hash" do
        returned_reading = service.find_by_number(1)
        expect(returned_reading[:temperature]).to eq(10)
      end
    end
  end

  describe "create_async" do
    it "queues job to persist reading" do
      expect {
        service.create_async(valid_params)
      }.to change(ReadingPersister.jobs, :size).by(1)
    end

    it "returns sequence number" do
      number = service.create_async(valid_params)
      expect(number).to eq(1)
    end

    it "add attributes to cache" do
      number = service.create_async(valid_params)
      expect(service.reading_cache.get(number)).not_to be_nil
    end
  end

  describe "create" do
    it "saves params to database" do
      expect{
        service.create(valid_params)
      }.to change(Reading, :count).by(1)
    end

    it "returns Reading object" do
      reading = service.create(valid_params)
      expect(reading).to eq(Reading.last)
    end

    it "removes params from cache" do
      number = service.create_async(valid_params)
      expect(service.reading_cache.get(number)).not_to be_nil
      service.create(valid_params.merge({number: number}))
      expect(service.reading_cache.get(number)).to be_nil
    end
  end

  describe "next sequence number" do
    context "with no current readings" do
      it "returns 1" do
        expect(service.next_sequence_number).to eq(1)
      end
    end

    context "with one reading in database" do
      let!(:reading) { create(:reading, thermostat: thermostat) }

      it "returns 2" do
        expect(service.next_sequence_number).to eq(2)
      end
    end

    context "with one reading in cache" do
      it "returns 2" do
        service.create_async(valid_params)
        expect(service.next_sequence_number).to eq(2)
      end
    end
  end

  def valid_params
    attributes_for(:reading)
  end
end
