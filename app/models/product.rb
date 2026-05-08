class Product < ApplicationRecord
  has_one_attached :image
  after_commit -> { broadcast_refresh_later_to "products" }
  validates :title, :description, :image, presence: true
  validates :title, uniqueness: true
  validate :acceptable_image

  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/gif", "image/jpeg", "image/png" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a GIF, JPG or PNG image")
    end
  end

  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates_associated :reviews

  has_many :line_items
  has_many :reviews, dependent: :destroy, before_add: :check_review_limit, after_add: :log_review_added
  has_and_belongs_to_many :categories
  before_destroy :ensure_not_referenced_by_any_line_item
  
  private
    # ensure that there are no line items referencing this product
    def ensure_not_referenced_by_any_line_item
      unless line_items.empty?
      errors.add(:base, "Line Items present")
      throw :abort
    end

    def check_review_limit(review)
      if reviews.count >= 10
        errors.add(:base, "Cannot add more than 10 reviews")
        throw(:abort)
      end
    end

    def log_review_added(review)
      Rails.logger.info "📝 Review added to #{title}"
    end
  end

end
