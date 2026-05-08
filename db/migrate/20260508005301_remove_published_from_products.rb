class RemovePublishedFromProducts < ActiveRecord::Migration[8.1]
  def change
    remove_column :products, :published, :boolean
  end
end
