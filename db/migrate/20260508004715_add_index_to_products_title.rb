class AddIndexToProductsTitle < ActiveRecord::Migration[8.1]
  def change
    add_index :products, :title, unique: true
  end
end
