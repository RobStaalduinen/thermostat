class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  def render_404
    render json: {}, status: 404
  end
end
