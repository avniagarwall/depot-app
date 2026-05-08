class ChangeDefaultStockQuantityInProducts < ActiveRecord::Migration[8.1]
  def change
    change_column_default :products, :stock_quantity, from: nil, to: 0
  end
end
