class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string  :name,       null: false
      t.integer :parent_id,  null: true, index: true
      t.integer :products_count, default: 0, null: false

      t.timestamps
    end

    add_index :categories, [ :name, :parent_id ], unique: true
  end
end
