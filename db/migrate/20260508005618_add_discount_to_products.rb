class AddDiscountToProducts < ActiveRecord::Migration[8.1]
  def up
    add_column :products, :discount, :decimal, precision: 5, scale: 2
  end

  def down
    remove_column :products, :discount
  end
end
