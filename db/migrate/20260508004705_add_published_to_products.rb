class AddPublishedToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :published, :boolean, null: false, default: false
  end
end
