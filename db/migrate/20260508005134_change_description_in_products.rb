class ChangeDescriptionInProducts < ActiveRecord::Migration[8.1]
  def change
    reversible do |direction|
      direction.up   { change_column :products, :description, :text }
      direction.down { change_column :products, :description, :string }
    end
  end
end
