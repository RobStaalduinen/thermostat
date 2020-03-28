describe ReadingsController do
  let!(:thermostat) { create(:thermostat) }
  
  describe "show" do
    let!(:reading) { create(:reading, thermostat: thermostat) }

    describe "Authentication" do
      context "with no household token" do
        it "returns unauthorized status" do
          get :show, params: { thermostat_id: thermostat.id, number: reading.number }
          expect(response.status).to eq(401)
        end
      end

      context "with incorrect household token for thermostat" do
        it "returns unauthorized status" do
          get :show, params: { thermostat_id: thermostat.id, household_token: 'incorrect', number: reading.number }
          expect(response.status).to eq(401)
        end
      end

      context "with correct household token for thermostat" do
        it "returns success" do
          get :show, params: auth_params.merge({number: reading.number})
          expect(response.status).to eq(200)
        end
      end
      
      context "with missing reading" do
        it "returns not found" do
          get :show, params: auth_params.merge({number: 99999})
          expect(response.status).to eq(404)
        end
      end

      context "with reading existing in database" do
        it "returns success" do
          get :show, params: auth_params.merge({number: reading.number})
          expect(response.status).to eq(200)
        end

        it "returns reading data" do
          get :show, params: auth_params.merge({number: reading.number})
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['temperature']).to eq(reading.temperature)
          expect(parsed_response['humidity']).to eq(reading.humidity)
          expect(parsed_response['battery_charge']).to eq(reading.battery_charge)
        end
      end
    end

  end

  describe "create" do

    describe "Authentication" do
      context "with no household token" do
        it "returns unauthorized status" do
          post :create, params: { thermostat_id: thermostat.id }
          expect(response.status).to eq(401)
        end
      end

      context "with incorrect household token for thermostat" do
        it "returns unauthorized status" do
          post :create, params: { thermostat_id: thermostat.id, household_token: 'incorrect' }
          expect(response.status).to eq(401)
        end
      end

      context "with correct household token for thermostat" do
        it "returns success" do
          post :create, params: valid_params
          expect(response.status).to eq(200)
        end
      end


      
    end

    context "with missing theormostat" do
      it "returns not found" do
        post :create, params: { thermostat_id: 999999 }
        expect(response.status).to eq(404)
      end
    end

    context "with valid thermostat" do
      it "queues a ReadingPersister worker" do
        expect {
          post :create, params: valid_params
        }.to change(ReadingPersister.jobs, :size).by(1)
      end

      it "creates a new reading in background" do
        Sidekiq::Testing.inline! do
          expect{
            post :create, params: valid_params
          }.to change(Reading, :count).by(1)
        end
      end

      it "creates a reading with correct attributes" do
        Sidekiq::Testing.inline! do
          post :create, params: valid_params
          reading = Reading.last
          expect(reading.thermostat).to eq(thermostat)
          expect(reading.temperature).to eq(valid_params[:reading][:temperature])
          expect(reading.humidity).to eq(valid_params[:reading][:humidity])
          expect(reading.battery_charge).to eq(valid_params[:reading][:battery_charge])
        end
      end

      it "returns sequence number" do
        Sidekiq::Testing.inline! do
          post :create, params: valid_params
          parsed_response = JSON.parse(response.body)

          expect(parsed_response['number']).to eq(Reading.last.number)
        end
      end
    end

  end

  def valid_params
    auth_params.merge({
      reading: attributes_for(:reading).except(:number)
    })
  end

  def auth_params
    {
      thermostat_id: thermostat.id, 
      household_token: thermostat.household_token
    }
  end

end
