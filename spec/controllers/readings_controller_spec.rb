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
          post :create, params: { thermostat_id: thermostat.id, household_token: thermostat.household_token }
          expect(response.status).to eq(200)
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
          post :create, params: { thermostat_id: thermostat.id, household_token: thermostat.household_token }
          expect(response.status).to eq(200)
        end
      end
    end
    
  end

end
