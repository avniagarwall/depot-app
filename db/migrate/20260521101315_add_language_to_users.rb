class AddLanguageToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :language, :string, null: false, default: 'english'
  end
end
