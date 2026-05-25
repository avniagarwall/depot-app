class AddFieldsToProducts < ActiveRecord::Migration[8.1]

  # 1. Add following columns to the products
  # a. enabled(boolean), no default value
  # b. discount_price(decimal)
  # c. permalink(string)

  def change
    change_table :products do |t|
      t.boolean :enabled
      t.decimal :discount_price, precision: 8, scale: 2
      t.string  :permalink
  end
end
