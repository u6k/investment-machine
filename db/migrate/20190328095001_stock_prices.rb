class StockPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_prices do |t|
      t.string :ticker_symbol
      t.date :date
      t.integer :opening_price
      t.integer :high_price
      t.integer :low_price
      t.integer :close_price
    end
  end
end
