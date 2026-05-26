class ChangeProductTypeInProducts < ActiveRecord::Migration[8.1]
  def change
    change_column :products, :product_type, :text
  end
end
