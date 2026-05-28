class Product < ApplicationRecord
  ACCEPTABLE_IMAGE_TYPES = [ "image/gif", "image/jpeg", "image/png" ].freeze
  VALIDATE_PERMALINK_REGEX = /\A[a-z0-9]+(-[a-z0-9]+){2,}\z/

  # Associations
  belongs_to :category, optional: true, counter_cache: true
  has_many :line_items, dependent: :restrict_with_error
  has_many :carts, through: :line_items
  has_many_attached :images

  # Callbacks
  after_commit     -> { broadcast_refresh_later_to "products" }
  after_initialize :set_defaults

  # Scopes
  scope :enabled,                -> { where(available: true) }
  scope :in_any_line_item,       -> { joins(:line_items).distinct }
  scope :titles_in_any_line_item, -> { in_any_line_item.pluck(:title) }

  # Validations
  validates :title, presence: true,
                    uniqueness: { allow_blank: true, case_sensitive: false }

  validates :description, presence: true,
                          uniqueness: { allow_blank: true, case_sensitive: false }

  validates :price, numericality: { greater_than_or_equal_to: 0.01 },
                    allow_blank: true

  validates :permalink, uniqueness: true,
                        format: {
                          with: VALIDATE_PERMALINK_REGEX,
                          message: :invalid_permalink
                        }

  validates :images, presence: true

  validate :acceptable_images
  validate :maximum_three_images
  validate :description_word_count
  validate :price_greater_than_discount_price

  private

    def set_defaults
      self.title          ||= "abc"
      self.discount_price ||= price
    end

    def acceptable_images
      images.each do |image|
        unless ACCEPTABLE_IMAGE_TYPES.include?(image.content_type)
          errors.add(:images, :invalid_image)
          break
        end
      end
    end

    def maximum_three_images
      if images.size > 3
        errors.add(:images, :too_many_images)
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