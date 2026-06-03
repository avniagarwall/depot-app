class Category < ApplicationRecord
  # Associations
  belongs_to :parent, class_name: "Category", optional: true
  has_many   :sub_categories, class_name: "Category",
                               foreign_key: :parent_id,
                               dependent: :destroy,
                               inverse_of: :parent

  has_many :products, foreign_key: :category_id
  has_many :sub_category_products, through: :sub_categories,
                                    source: :products

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: {
    scope: :parent_id,
    case_sensitive: false,
    message: :taken
  }, allow_blank: true

  validate :cannot_be_sub_category_of_sub_category, if: :parent_id?

  before_destroy :ensure_no_products_associated
  after_destroy  :update_parent_count

  # Counter cache
  after_save     :update_parent_count, if: :saved_change_to_products_count?

  # Scopes
  scope :root,       -> { where(parent_id: nil) }
  scope :with_subs,  -> { includes(:sub_categories) }

  def all_products
    Product.where(category_id: [ id, *sub_categories.pluck(:id) ])
  end

  def root?
    parent_id.nil?
  end

  private

    def cannot_be_sub_category_of_sub_category
      if parent&.parent_id?
        errors.add(:base, :no_deep_nesting)
      end
    end

    def ensure_no_products_associated
      if products.exists?
        errors.add(:base, :products_present)
        throw :abort
      end

      if sub_category_products.exists?
        errors.add(:base, :sub_category_products_present)
        throw :abort
      end

    end

    def update_parent_count
      return unless parent
      parent.update_column(:products_count,
        parent.products.count + parent.sub_category_products.count)
    end
end