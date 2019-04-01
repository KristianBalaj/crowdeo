class User < ApplicationRecord
  before_save { self.email = email.downcase }
  validates :nick_name,
            presence: true,
            length: { maximum: 25 },
            uniqueness: true
  validate :check_nick_name_empty_spaces
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: URI::MailTo::EMAIL_REGEXP,
            uniqueness: { case_sensitive: false }
  validates :password,
            presence: true,
            length: { minimum: 6 }
  has_secure_password

  # when there is a whitespace in the nick name, an error is added
  def check_nick_name_empty_spaces
    if self.nick_name.match(/\s+/)
      errors.add(:nick_name, "can't contain white spaces")
    end
  end

end
