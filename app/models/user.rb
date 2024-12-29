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

end
