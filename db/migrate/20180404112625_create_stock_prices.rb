class CreateStockPrices < ActiveRecord::Migration[5.1]
  def change
    create_table :stock_prices do |t|
      t.date :date
      t.integer :opening_price
      t.integer :high_price
      t.integer :low_price
      t.integer :close_price
      t.integer :turnover
      t.integer :adjustment_value
      t.references :stock, foreign_key: true

      t.timestamps
    end
  end
end
