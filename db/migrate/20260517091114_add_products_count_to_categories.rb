class AddProductsCountToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :categories, :products_count, :integer, null: false, default: 0
  end
end
