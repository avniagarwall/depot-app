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

  # before_validation
  before_validation :strip_reviewer_name

  # after_validation
  after_validation :log_validation_errors

  # before_save
  before_save :capitalize_reviewer_name

  # after_create
  after_create :log_new_review

  # after_update
  after_update :log_review_update

  # before_destroy
  before_destroy :check_if_only_review

  # after_destroy
  after_destroy ReviewLogger

  # after_commit
  after_commit ReviewLogger

  # after_initialize
  after_initialize :log_initialization

  # conditional callback - only log if rating is low
  after_create :flag_low_rating, if: :low_rating?

  private

    def strip_reviewer_name
      self.reviewer_name = reviewer_name.strip if reviewer_name.present?
    end

    def log_validation_errors
      if errors.any?
        Rails.logger.error("Review validation failed: #{errors.full_messages.join(', ')}")
      end
    end

    def capitalize_reviewer_name
      self.reviewer_name = reviewer_name.strip.titleize
    end

    def log_new_review
      Rails.logger.info "⭐ New review for #{product.title} — Rating: #{rating}/5"
    end

    def log_review_update
      Rails.logger.info "✏️ Review updated for #{product.title}"
    end

    def check_if_only_review
      if product.reviews.count == 1
        errors.add(:base, "Cannot delete the only review for this product")
        throw :abort
      end
    end

    def log_review_deletion
      Rails.logger.info "🗑️ Review by #{reviewer_name} deleted"
    end

    def log_committed_review
      Rails.logger.info "✅ Review committed to database for #{product.title}"
    end

    def log_initialization
      Rails.logger.info "Review object initialized"
    end

    def flag_low_rating
      Rails.logger.warn "⚠️ Low rating (#{rating}/5) received for #{product.title}"
    end

    def low_rating?
      rating.present? && rating <= 2
    end

    def no_spam_in_body
      if body.present? && body.downcase.include?("spam")
        errors.add(:body, "cannot contain spam content")
      end
    end
end