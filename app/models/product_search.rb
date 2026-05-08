class ProductSearch
  # ACTIVE MODEL ATTRIBUTES
  # Allows type casting, defaults and serialization on plain Ruby objects
  include ActiveModel::API
  include ActiveModel::Attributes

  # attribute with type and default value
  attribute :query,      :string
  attribute :min_price,  :decimal, default: 0.0
  attribute :max_price,  :decimal, default: 999.99
  attribute :in_stock,   :boolean, default: true
  attribute :page,       :integer, default: 1

  # VALIDATIONS
  validates :min_price, numericality: { greater_than_or_equal_to: 0 }
  validates :max_price, numericality: { greater_than: 0 }

  def results
    scope = Product.all
    scope = scope.where("title LIKE ?", "%#{query}%") if query.present?
    scope = scope.where("price >= ?", min_price) if min_price.present?
    scope = scope.where("price <= ?", max_price) if max_price.present?
    scope
  end
end