describe ReadingsController do
  let!(:thermostat) { create(:thermostat) }

  describe "show" do

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

    describe "Creation" do
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

  end

  def valid_params
    { 
      thermostat_id: thermostat.id, 
      household_token: thermostat.household_token,
      reading: attributes_for(:reading).except(:number)
    }
  end



end
