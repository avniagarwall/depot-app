class User < ApplicationRecord
  VALIDATE_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
  validates :name, presence: true

  # Email uniqueness (already present) + case insensitive
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }

  # Email format
  validates :email_address, format: {
    with: VALIDATE_EMAIL_REGEX,
    message: :invalid_email
  }

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_create  :send_welcome_email   # Exercise 3
  before_update :prevent_admin_update # Exercise 5
  before_destroy :prevent_admin_destroy   # Exercise 4
  after_destroy :ensure_an_admin_remains  # existing

  class AdminDeletionError < StandardError; end

  private

    def send_welcome_email
      UserMailer.welcome_email(self).deliver_later
    end

    def prevent_admin_update
      if email_address_was == "admin@depot.com"
        errors.add(:base, "Cannot modify the admin user")
        throw :abort
      end
    end

    def prevent_admin_destroy
      if email_address == "admin@depot.com"
        errors.add(:base, "Cannot delete the admin user")
        throw :abort
      end
    end

    def ensure_an_admin_remains
      if User.count.zero?
        raise AdminDeletionError, Il8n.t("errors.admin_deletion")
      end
    end
end
