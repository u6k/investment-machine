class AddIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :stock_prices, :ticker_symbol
    add_index :stock_prices, :date

    add_index :companies, :ticker_symbol

    add_index :nikkei_averages, :date

    add_index :topixes, :date

    add_index :djia, :date
  end
end
