class ApplicationController < ActionController::API
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login])
  end
end
