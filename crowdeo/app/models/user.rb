class User < ApplicationRecord
  before_save { self.email = email.downcase }
  validates :nick_name,
            presence: true,
            length: { maximum: 25 },
            uniqueness: true
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: URI::MailTo::EMAIL_REGEXP,
            uniqueness: { case_sensitive: false }
  validates :password,
            presence: true,
            length: { minimum: 6 }
  has_secure_password
end
