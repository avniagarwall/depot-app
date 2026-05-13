class ChangeEnabledDefaultInProducts < ActiveRecord::Migration[8.1]

  # 2. Now change default value of enabled field to false

  def change
    change_column_default :products, :enabled, from: nil, to: false
  end
end
