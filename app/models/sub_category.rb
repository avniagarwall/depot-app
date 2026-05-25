class SubCategory < ApplicationRecord
  # Associations
  belongs_to :category
  has_many   :products, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :name,
            uniqueness: { scope: :category_id, case_sensitive: false,
                          message: "already exists in this category" },
            if: :name?

  # No child nesting — sub_category is always a leaf
  # (enforced by design: SubCategory has no has_many :sub_categories)

  # Callbacks
  after_save    :update_parent_count
  after_destroy :update_parent_count

  private

  def update_parent_count
    category&.recalculate_products_count!
  end
end