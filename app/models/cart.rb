class Cart < ApplicationRecord
    has_many :line_items, dependent: :destroy

    # 2. Create an association on cart through which we could get all the products associated with the cart.
    has_many :products, through: :line_items
    
    # 4. Create an association on cart model through which I could get all enabled products associated with it.
    has_many :enabled_products, -> { where(enabled: true) },
         through: :line_items,
         source: :product

    def add_product(product)
        current_item = line_items.find_by(product_id: product.id)
        if current_item
            current_item.quantity += 1
        else
            current_item = line_items.build(product_id: product.id)
        end
        current_item
    end

    def total_price
        line_items.sum { |item| item.total_price }
    end
end
