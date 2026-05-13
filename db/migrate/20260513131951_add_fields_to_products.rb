class AddFieldsToProducts < ActiveRecord::Migration[8.1]

  # 1. Add following columns to the products
  # a. enabled(boolean), no default value
  # b. discount_price(decimal)
  # c. permalink(string)

  def change
    add_column :products, :enabled, :boolean
    add_column :products, :discount_price, :decimal, precision: 8, scale: 2
    add_column :products, :permalink,      :string
  end
end
