class AddLineItemsCountToCarts < ActiveRecord::Migration[8.1]

  # 4. Add following to cart
  # a. line_items_count(integer), default: 0, not null
  
  def change
    add_column :carts, :line_items_count, :integer, default: 0, null: false
  end
end
