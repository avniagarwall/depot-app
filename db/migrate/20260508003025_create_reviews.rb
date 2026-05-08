class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :rating
      t.text :body
      t.string :reviewer_name

      t.timestamps
    end
  end
end
