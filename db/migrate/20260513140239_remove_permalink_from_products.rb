class RemovePermalinkFromProducts < ActiveRecord::Migration[8.1]

  # 7. Revise irreversible migration, and make an example of irreversible migration

  def up
    remove_column :products, :permalink
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Data in :permalink was destroyed and cannot be recovered."
  end
end
