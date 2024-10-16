class User < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable
  has_many :posts
  validates :email, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["admin", "confirmation_sent_at", "confirmation_token", "confirmed_at", "created_at", "current_sign_in_at", "current_sign_in_ip", "email", "failed_attempts", "first_name", "id", "last_name", "last_sign_in_at", "last_sign_in_ip", "locked_at", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "unconfirmed_email", "unlock_token", "updated_at"]
  end

  def display_name
    if first_name?
      "#{first_name} #{last_name}"
    else
      email
    end
  end
  alias name display_name
end
