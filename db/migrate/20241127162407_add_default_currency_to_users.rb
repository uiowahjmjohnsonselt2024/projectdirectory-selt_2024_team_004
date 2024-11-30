class AddDefaultCurrencyToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :default_currency, :string
  end
end
