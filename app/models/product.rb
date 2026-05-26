class Product < ApplicationRecord
  ACCEPTABLE_IMAGE_TYPES = [ "image/gif", "image/jpeg", "image/png" ]
  VALIDATE_PERMALINK_REGEX = /\A[a-z0-9]+(-[a-z0-9]+){2,}\z/

  has_many :carts, through: :line_items
  has_many :line_items, dependent: :restrict_with_error
  
  has_one_attached :image
  after_commit -> { broadcast_refresh_later_to "products" }
  after_initialize :set_defaults

  # 1. Make a scope for all the enabled products
  scope :enabled, -> { where(available:true) }

  # 3. Build queries for following
  #  - Get All products which are present in atleast one line_item
  #  - Get array of product titles which are present in atleast one line item
  scope :in_any_line_item,        -> { joins(:line_items).distinct }
  scope :titles_in_any_line_item, -> { in_any_line_item.pluck(:title) }
  
  # Existing validations
  validates :title, presence: true, uniqueness: { allow_blank: true, case_sensitive: false }
  validates :image, presence: true
  validate :acceptable_image

  # Description: between 5 and 10 words
  validates :description, presence: true, uniqueness: { allow_blank: true, case_sensitive: false }
  validate :description_word_count

  # Price: numericality only if price is present
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }, allow_blank: true

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
      self.title ||= "abc"
      self.discount_price ||= price
    end

    def acceptable_image
      return unless image.attached?

      unless ACCEPTABLE_IMAGE_TYPES.include?(image.content_type)
        errors.add(:image, :invalid_image)
      end
    end

    def description_word_count
      return if description.blank?

      count = description.split.size
      unless count.between?(5, 10)
        errors.add(:description, :invalid_word_count, count: count)
      end
    end

    def price_greater_than_discount_price
      return if price.blank? || discount_price.blank?

      if price <= discount_price
        errors.add(:price, :invalid_price)
      end
    end
end
