class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  has_many :lists, dependent: :destroy

  attr_accessor :login

  validates :first_name, :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)

    if login
      where(conditions).where(["phone_number = :value OR email = :value", { value: login }]).first
    else
      where(conditions).first
    end
  end

  def google_credentials
    Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      token: google_token,
      refresh_token: google_refresh_token,
      expires_at: google_token_expires_at
    )
  end

  def update_google_tokens(credentials)
    update(
      google_token: credentials[:token],
      google_refresh_token: credentials[:refresh_token],
      google_token_expires_at: Time.at(credentials[:expires_at])
    )
  end
end
