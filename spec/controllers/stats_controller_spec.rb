describe StatsController do
  let!(:thermostat) { create(:thermostat) }

  describe "index" do
    describe "Authentication" do
      context "with no household token" do
        it "returns unauthorized status" do
          get :index, params: { thermostat_id: thermostat.id }
          expect(response.status).to eq(401)
        end
      end

      context "with incorrect household token for thermostat" do
        it "returns unauthorized status" do
          get :index, params: { thermostat_id: thermostat.id, household_token: 'incorrect' }
          expect(response.status).to eq(401)
        end
      end

      context "with correct household token for thermostat" do
        it "returns success" do
          get :index, params: auth_params
          expect(response.status).to eq(200)
        end
      end
    end

    context "with no readings" do
      it "returns zero for all stats" do
        get :index, params: auth_params
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['temperature']['average']).to eq(0)
        expect(parsed_response['temperature']['min']).to eq(0)
        expect(parsed_response['temperature']['max']).to eq(0)

        expect(parsed_response['humidity']['average']).to eq(0)
        expect(parsed_response['humidity']['min']).to eq(0)
        expect(parsed_response['humidity']['max']).to eq(0)

        expect(parsed_response['battery_charge']['average']).to eq(0)
        expect(parsed_response['battery_charge']['min']).to eq(0)
        expect(parsed_response['battery_charge']['max']).to eq(0)
      end
    end

    context "with a single reading" do
      let!(:reading) { create(:reading, thermostat: thermostat) }

      it "matches value for single reading" do
        get :index, params: auth_params
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['temperature']['average']).to eq(reading.temperature)
        expect(parsed_response['temperature']['min']).to eq(reading.temperature)
        expect(parsed_response['temperature']['max']).to eq(reading.temperature)

        expect(parsed_response['humidity']['average']).to eq(reading.humidity)
        expect(parsed_response['humidity']['min']).to eq(reading.humidity)
        expect(parsed_response['humidity']['max']).to eq(reading.humidity)

        expect(parsed_response['battery_charge']['average']).to eq(reading.battery_charge)
        expect(parsed_response['battery_charge']['min']).to eq(reading.battery_charge)
        expect(parsed_response['battery_charge']['max']).to eq(reading.battery_charge)
      end
    end

    context "with multiple readings for thermostat" do
      let!(:first_reading) { create(:reading, thermostat: thermostat, temperature: 10.0, humidity: 10.0, battery_charge: 10.0) }
      let!(:second_reading) { create(:reading, thermostat: thermostat, temperature: 20.0, humidity: 20.0, battery_charge: 20.0) }

      it "calculates aggregated stats" do
        get :index, params: auth_params
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['temperature']['average']).to eq(15.0)
        expect(parsed_response['temperature']['min']).to eq(10.0)
        expect(parsed_response['temperature']['max']).to eq(20.0)

        expect(parsed_response['humidity']['average']).to eq(15.0)
        expect(parsed_response['humidity']['min']).to eq(10.0)
        expect(parsed_response['humidity']['max']).to eq(20.0)

        expect(parsed_response['battery_charge']['average']).to eq(15.0)
        expect(parsed_response['battery_charge']['min']).to eq(10.0)
        expect(parsed_response['battery_charge']['max']).to eq(20.0)
      end
    end

    context "with readings for multiple thermostats" do
      let!(:reading) { create(:reading, thermostat: thermostat) }
      let!(:second_thermostat) { create(:thermostat) }
      let!(:second_reading) { create(:reading) }

      it "only includes value for specified thermostat" do
        get :index, params: auth_params
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['temperature']['average']).to eq(reading.temperature)
        expect(parsed_response['temperature']['min']).to eq(reading.temperature)
        expect(parsed_response['temperature']['max']).to eq(reading.temperature)

        expect(parsed_response['humidity']['average']).to eq(reading.humidity)
        expect(parsed_response['humidity']['min']).to eq(reading.humidity)
        expect(parsed_response['humidity']['max']).to eq(reading.humidity)

        expect(parsed_response['battery_charge']['average']).to eq(reading.battery_charge)
        expect(parsed_response['battery_charge']['min']).to eq(reading.battery_charge)
        expect(parsed_response['battery_charge']['max']).to eq(reading.battery_charge)
      end

    end

  end

  def auth_params
    {
      thermostat_id: thermostat.id, 
      household_token: thermostat.household_token
    }
  end

end
