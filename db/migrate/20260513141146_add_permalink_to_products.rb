class AddPermalinkToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :permalink, :string
  end
end
