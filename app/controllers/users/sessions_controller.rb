# frozen_string_literal: true
require 'googleauth/stores/file_token_store'
require 'google/apis/calendar_v3'
require 'googleauth'

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  before_action :set_user, only: %i[show update_info]
  skip_before_action :authenticate_user!, only: [:google_oauth_url, :google_oauth_callback]

  def show
    render json: @user
  end

  def create
    user = User.find_by('email = ? OR phone_number = ?', sign_in_params[:login], sign_in_params[:login])
    if user&.valid_password?(sign_in_params[:password])
      token = encode_jwt(user)
      render json: { token: token, message: 'Signed in successfully' }, status: :ok
    else
      render json: { error: 'Invalid login or password' }, status: :unauthorized
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def update_info
    if @user.update(sign_in_params)
      render json: { message: 'User updated successfully' }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      Warden::JWTAuth::TokenRevoker.new.call(token)
      render json: { message: 'Signed out successfully' }, status: :ok
    else
      render json: { error: 'No token provided' }, status: :unauthorized
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def google_oauth_url
    client_id = Google::Auth::ClientId.from_file('config/google_api_credentials.json')
    authorizer = Google::Auth::UserAuthorizer.new(client_id, Google::Apis::CalendarV3::AUTH_CALENDAR, nil, google_oauth_callback_users_sessions_path)

    # Use the correct helper method name
    authorization_url = authorizer.get_authorization_url(base_url: "http://127.0.0.1:3000/users/sessions/google_oauth_callback")
    render json: { url: authorization_url }, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to generate Google OAuth URL: #{e.message}" }, status: :internal_server_error
  end

  def google_oauth_callback
    client_id = Google::Auth::ClientId.from_file('config/google_api_credentials.json')

    # Define a token store
    token_store = Google::Auth::Stores::FileTokenStore.new(file: 'config/google_tokens.yaml')

    authorizer = Google::Auth::UserAuthorizer.new(
      client_id,
      Google::Apis::CalendarV3::AUTH_CALENDAR,
      token_store,
      google_oauth_callback_users_sessions_path
    )

    current_user = User.first

    if current_user.nil?
      render json: { error: 'User not authenticated' }, status: :unauthorized and return
    end

    begin
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: current_user.id.to_s,
        code: params[:code],
        base_url: "http://127.0.0.1:3000/users/sessions/google_oauth_callback"
      )

      # Store credentials in the database
      current_user.update(
        google_token: credentials.access_token,
        google_refresh_token: credentials.refresh_token,
        google_token_expires_at: credentials.expires_at
      )

      render json: { message: 'Google account connected successfully' }, status: :ok
    rescue StandardError => e
      Rails.logger.error("Google OAuth Error: #{e.message}")
      render json: { error: "Failed to authenticate with Google: #{e.message}" }, status: :unprocessable_entity
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def sign_in_params
    params.require(:user).permit(:login, :password, :first_name, :last_name, :email, :phone_number)
  end

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login])
  end

  def encode_jwt(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end
end
