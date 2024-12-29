# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  before_action :set_user, only: %i[ show update_info ]

  def show
    render json: @user
  end

  def create
    user = User.find_by('email = ? OR phone_number = ?', sign_in_params[:login], sign_in_params[:login])
    if user&.valid_password?(sign_in_params[:password])
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
      render json: { token: token, message: 'Signed in successfully' }, status: :ok
    else
      render json: { error: 'Invalid login or password' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  rescue ArgumentError, NoMethodError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  def update_info
    if @user.update(sign_in_params)
      render json: { message: 'User updated successfully' }, status: :ok
    else
      render json: { message: 'Failed' }, status: :unauthorized
    end
  end

  def destroy
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      Warden::JWTAuth::RevocationStrategies::Denylist.revoke_jwt(token, nil)
      render json: { message: 'Signed out successfully' }, status: :ok
    else
      render json: { error: 'No token provided' }, status: :unauthorized
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def sign_in_params
    params.require(:user).permit(:login, :password, :first_name, :last_name)
  end

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login])
  end
end
