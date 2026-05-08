class Review < ApplicationRecord

  # ASSOCIATIONS
  belongs_to :product

  # VALIDATIONS

  # presence
  validates :reviewer_name, presence: true
  validates :body,          presence: true
  validates :rating,        presence: true

  # length
  validates :reviewer_name, length: { minimum: 2, maximum: 50 }
  validates :body,          length: { minimum: 10, maximum: 1000 }

  # numericality
  validates :rating, numericality: { only_integer: true, in: 1..5 }

  # validates_with - passes record to a separate validator class
  validates_with RatingRangeValidator

  # conditional validations
  # only validate body length if body is present (:if with proc)
  validates :body, length: { minimum: 10 }, if: -> { body.present? }

  # inclusion
  validates :rating, inclusion: {
    in: 1..5,
    message: "%{value} is not a valid rating. Choose between 1 and 5"
  }

  # format - only on create
  validates :reviewer_name, format: {
    with: /\A[a-zA-Z\s]+\z/,
    message: "only allows letters"
  }, on: :create

  # uniqueness - one review per product per reviewer
  validates :reviewer_name, uniqueness: {
    scope: :product_id,
    message: "has already reviewed this product"
  }

  # custom validation method
  validate :no_spam_in_body

  # CALLBACKS
  before_save  :capitalize_reviewer_name
  after_create :log_new_review

  private

    def capitalize_reviewer_name
      self.reviewer_name = reviewer_name.strip.titleize
    end

    def log_new_review
      Rails.logger.info "⭐ New review for #{product.title} — Rating: #{rating}/5"
    end

    def no_spam_in_body
      if body.present? && body.downcase.include?("spam")
        errors.add(:body, "cannot contain spam content")
      end
    end
end