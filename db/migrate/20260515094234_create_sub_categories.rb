class CreateSubCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :sub_categories do |t|
      t.references :category,    null: false, foreign_key: true
      t.string     :name,        null: false
      t.string     :description
      t.boolean    :active,      null: false, default: true

      t.timestamps
    end

    add_index :sub_categories, [:category_id, :name], unique: true
  end
end
