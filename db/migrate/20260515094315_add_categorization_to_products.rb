class AddCategorizationToProducts < ActiveRecord::Migration[8.1]
  def change
    add_reference :products, :category,     foreign_key: true, null: true
    add_reference :products, :sub_category, foreign_key: true, null: true

    # Create a default "Uncategorized" category for existing products
    reversible do |dir|
      dir.up do
        # Insert a default category
        default_category_id = execute(
          "INSERT INTO categories (name, active, created_at, updated_at)
           VALUES ('Uncategorized', 1, datetime('now'), datetime('now'))
           RETURNING id"
        ).first["id"]

        # Assign all existing products to it
        execute("UPDATE products SET category_id = #{default_category_id} WHERE category_id IS NULL AND sub_category_id IS NULL")

        # Now it's safe to add the check constraint
        add_check_constraint :products,
          "(category_id IS NOT NULL AND sub_category_id IS NULL) OR
           (category_id IS NULL AND sub_category_id IS NOT NULL)",
          name: "product_belongs_to_one_categorization"
      end

      dir.down do
        remove_check_constraint :products, name: "product_belongs_to_one_categorization"
      end
    end
  end
end
