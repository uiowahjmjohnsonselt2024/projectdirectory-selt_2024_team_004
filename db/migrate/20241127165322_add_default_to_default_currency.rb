class AddDefaultToDefaultCurrency < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :default_currency, 'USD'
  end
end
