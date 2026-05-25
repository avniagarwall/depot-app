class User < ApplicationRecord
  validates :name, presence: true

  # Email uniqueness (already present) + case insensitive
  validates :email_address, presence: true, uniqueness: { if: :email_address? }

  # Email format
  validates :email_address, format: {
    with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/,
    message: "must be a valid email address"
  }
  validates :language, inclusion: { in: %w[english hindi] }

  def locale
    language == 'hindi' ? :hi : :en
  end

  enum :role, { user: 'user', admin: 'admin' }, prefix: true

  def admin?
    role == 'admin'
  end

  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :orders
  has_many :line_items, through: :orders
  
  has_one  :address, dependent: :destroy
  accepts_nested_attributes_for :address, update_only: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_create  :send_welcome_email   # Exercise 3
  before_update :prevent_admin_update # Exercise 5
  before_destroy :prevent_admin_destroy   # Exercise 4
  after_destroy :ensure_an_admin_remains  # existing

  class Error < StandardError; end

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
        raise Error.new "Can't delete last user"
      end
    end
end
