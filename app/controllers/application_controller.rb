class ApplicationController < ActionController::API
  before_action :authenticate_user!

  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end
end
