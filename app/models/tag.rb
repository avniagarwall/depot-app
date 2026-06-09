class Tag < ApplicationRecord
  has_many :product_tags, dependent: :destroy
  has_many :products, through: :product_tags

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }, if: :name?

  before_save :normalize_name, if: :name_changed?
  after_destroy :destroy_product_without_tags

  scope :ordered, -> { order(:name) }

  private def normalize_name
      self.name = name.strip.titleize
    end

  private def destroy_product_without_tags
    products.each do |product|
      product.destroy if product.tags.empty?
    end
  end
end
