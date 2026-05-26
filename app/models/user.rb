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

  after_destroy :ensure_an_admin_remains

  class AdminDeletionError < StandardError; end

  private
    def ensure_an_admin_remains
      if User.count.zero?
        raise AdminDeletionError, I18n.t("errors.admin_deletion")
      end
    end
end
