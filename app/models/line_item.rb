class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product

  # 5. Everytime a line_item is added or removed from cart, 
  # line_items_count column in cart table should be automatically incremented or decremented . - Done
  belongs_to :cart, optional: true, counter_cache: true

  # Unique combination of product_id and cart_id
  validates :product_id, uniqueness: {
    scope: :cart_id,
    message: "has already been added to this cart"
  }, if: -> { cart_id.present? }

  def total_price
    product.price * quantity
  end
end