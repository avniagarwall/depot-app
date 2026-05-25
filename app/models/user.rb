class User < ApplicationRecord
  validates :name, presence: true

  # Email uniqueness (already present) + case insensitive
  validates :email_address, presence: true, uniqueness: { if: :email_address? }

  # Email format
  validates :email_address, format: {
    with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/,
    message: "must be a valid email address"
  }

  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_destroy :ensure_an_admin_remains

  class Error < StandardError
  end

  private
    def ensure_an_admin_remains
      if User.count.zero?
        raise Error.new "Can't delete last user"
      end
    end
end
