module Authorizable
  extend ActiveSupport::Concern

  included do
    before_action :authorize_thermostat

    rescue_from AuthenticationError, :with => :render_401
    
    def authorize_thermostat
      raise AuthenticationError unless authorized?
    end

    def authorized?
      thermostat.present? && 
      params[:household_token].present? && 
      params[:household_token] == thermostat.household_token
    end

    def thermostat
      @thermostat ||= Thermostat.find(params[:thermostat_id])
    end

    def render_401
      render json: { message: "Not authorized for this thermostat" }, status: 401
    end
  end

end
