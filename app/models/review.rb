class Review < ApplicationRecord
  # ASSOCIATIONS
  belongs_to :product

  # VALIDATIONS
  validates :reviewer_name, presence: true
  validates :body,          presence: true
  validates :rating,        numericality: { only_integer: true, in: 1..5 }

  # CALLBACKS
  after_create  :log_new_review
  before_save   :capitalize_reviewer_name

  private

    def capitalize_reviewer_name
      self.reviewer_name = reviewer_name.strip.titleize
    end

    def log_new_review
      Rails.logger.info "⭐ New review for #{product.title} — Rating: #{rating}/5"
    end
end