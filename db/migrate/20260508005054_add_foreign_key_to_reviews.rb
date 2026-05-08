class AddForeignKeyToReviews < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :reviews, :products
  end
end
