class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true, counter_cache: true

  # Unique combination of product_id and cart_id
  validates :product_id, uniqueness: {
    scope: :cart_id,
    message: :already_in_cart
  }, if: -> { cart_id.present? }

  def total_price
    product.price * quantity
  end
end
