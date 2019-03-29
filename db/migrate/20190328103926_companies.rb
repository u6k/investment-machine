class Companies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :ticker_symbol
      t.string :name
      t.string :market
    end
  end
end
