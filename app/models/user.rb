class User < ApplicationRecord
  ADMIN_EMAIL = "admin@depot.com".freeze
  VALIDATE_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :email_address, format: {
    with: VALIDATE_EMAIL_REGEX,
    message: :invalid_email
  }

  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :orders
  has_many :line_items, through: :orders

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_commit  :send_welcome_email, on: :create
  before_update :prevent_admin_update
  before_destroy :prevent_admin_destroy
  after_destroy :ensure_an_admin_remains

  class AdminDeletionError < StandardError; end

  private

    def send_welcome_email
      UserMailer.welcome_email(self).deliver_later
    end

    def prevent_admin_update
      if email_address_was == ADMIN_EMAIL
        errors.add(:base, :cannot_modify_admin)
        throw :abort
      end
    end

    def prevent_admin_destroy
      if email_address == ADMIN_EMAIL
        errors.add(:base, :cannot_delete_admin)
        throw :abort
      end
    end

    def ensure_an_admin_remains
      if User.count.zero?
        raise AdminDeletionError, I18n.t("errors.messages.admin_deletion")
      end
    end
end