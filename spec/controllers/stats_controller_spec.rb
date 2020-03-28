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

  end

  def auth_params
    {
      thermostat_id: thermostat.id, 
      household_token: thermostat.household_token
    }
  end

end
