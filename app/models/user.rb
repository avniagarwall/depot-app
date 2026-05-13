class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  # 3. add email to user - already present
  validates :email_address, presence: true, uniqueness: true
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
