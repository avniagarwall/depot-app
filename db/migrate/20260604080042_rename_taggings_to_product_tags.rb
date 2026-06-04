class RenameTaggingsToProductTags < ActiveRecord::Migration[8.1]
  def change
    rename_table :taggings, :product_tags
  end
end
