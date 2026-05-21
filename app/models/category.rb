class Category < ApplicationRecord
  # Associations
  has_many :sub_categories, dependent: :destroy

  # Products directly under this category
  has_many :products, dependent: :restrict_with_error

  # Products under sub_categories of this category
  has_many :sub_category_products,
           through: :sub_categories,
           source:  :products

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }, if: :name?

  # Callbacks
  before_destroy :ensure_no_products_in_subtree

  # All products reachable from this category (direct + via sub_categories)
  def all_products
    Product.where(category_id: id)
           .or(Product.where(sub_category_id: sub_category_ids))
  end

  # Recalculate and persist the products_count
  def recalculate_products_count!
    update_columns(products_count: all_products.count)
  end

  private

  def ensure_no_products_in_subtree
    if products.exists?
      errors.add(:base, "Cannot delete category because it has products associated with it")
      throw(:abort)
    end

    if sub_category_products.exists?
      errors.add(:base, "Cannot delete category because its sub-categories have products associated with them")
      throw(:abort)
    end

    # Safe to destroy — sub_categories will be wiped by dependent: :destroy
    true
  end
end
