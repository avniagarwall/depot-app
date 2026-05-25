class Product < ApplicationRecord
  ACCEPTABLE_IMAGE_TYPES = [ "image/gif", "image/jpeg", "image/png" ]
  has_many :carts, through: :line_items
  has_many :line_items, dependent: :restrict_with_error
  belongs_to :category,     optional: true
  belongs_to :sub_category, optional: true

  
  has_many_attached :images
  after_commit -> { broadcast_refresh_later_to "products" }
  after_initialize :set_defaults
  after_save    :update_category_count
  after_destroy :update_category_count

  # 1. Make a scope for all the enabled products
  scope :enabled, -> { where(available:true) }

  validate :must_belong_to_exactly_one_categorization

  # Existing validations
  validates :title, presence: true, uniqueness: { allow_blank: true, case_sensitive: false }
  validates :title, uniqueness: true
  validates :images, presence: true
  validate :acceptable_images
  validate :image_count_limit

  # Description: between 5 and 10 words
  validates :description, presence: true, uniqueness: { allow_blank: true, case_sensitive: false }
  validate :description_word_count

  # Price: numericality only if price is present
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }, allow_blank: true

  VALIDATE_PERMALINK_REGEX = /\A[a-z0-9]+(-[a-z0-9]+){2,}\z/

  # Permalink: unique, no special chars/spaces, min 3 hyphen-separated words
  validates :permalink, uniqueness: true,
                        format: {
                          with: VALIDATE_PERMALINK_REGEX,
                          message: :invalid_permalink
                        }

  # Image URL format using ActiveModel::EachValidator
  validates :image_url, url: true, allow_blank: true

  # Price > discount_price — WITH custom validator
  validate :price_greater_than_discount_price

  # Price > discount_price — WITHOUT custom validator
  # validates :price, numericality: {
  #   greater_than: :discount_price,
  #   message: "must be greater than discount price"
  # }, if: -> { price.present? && discount_price.present? }

  private

    # 1. Product should be always be initialized with default title 'abc' if no title given.
    # 2. Discount price should be equal to price unless specified explicitly.

    def set_defaults
      self.title ||= 'abc'
      self.discount_price ||= price
    end

    def acceptable_image
      return unless images.attached?
      images.each do |img|
        unless ACCEPTABLE_IMAGE_TYPES.include?(img.content_type)
          errors.add(:images, "must be GIF, JPG or PNG only")
        end
      end
    end

    def image_count_limit
      if images.length > 3
        errors.add(:images, "can have a maximum of 3 images")
      end
    end

    def description_word_count
      return if description.blank?

      count = description.split.size
      unless count.between?(5, 10)
        errors.add(:description, "must be between 5 and 10 words (currently #{count})")
      end
    end

    def price_greater_than_discount_price
      return if price.blank? || discount_price.blank?
      
      if price <= discount_price
        errors.add(:price, "must be greater than discount price")
      end
    end

    def must_belong_to_exactly_one_categorization
      if category_id.present? && sub_category_id.present?
        errors.add(:base, "Product can belong to a category OR a sub-category, not both")
      elsif category_id.blank? && sub_category_id.blank?
        errors.add(:base, "Product must belong to a category or a sub-category")
      end
    end

    def update_category_count
      # Refresh whichever category is affected
      target = category || sub_category&.category
      target&.recalculate_products_count!
    end
end