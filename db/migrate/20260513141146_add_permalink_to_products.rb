class AddPermalinkToProducts < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:products, :permalink)
      add_column :products, :permalink, :string
    end
  end
end
