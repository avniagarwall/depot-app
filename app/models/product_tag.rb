class ProductTag < ApplicationRecord
  belongs_to :tag
  belongs_to :product

  validates :tag_id, uniqueness: { scope: :product_id }
  # validate :product_must_be_published
  # validates :tag_id, numerical: { only_integer: true }

  # private def product_must_be_published
  #   if !product.published?
  #     errors.add(:product, "Must be published")
  #     errors.add(:product, "Must be published")
  #   end
  # end
end
