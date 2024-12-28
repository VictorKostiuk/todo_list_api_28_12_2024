# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    user = User.find_by_email(sign_in_params[:email])
    if user&.valid_password?(sign_in_params[:password])
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
      render json: { token: token, message: 'Signed in successfully' }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
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
end
