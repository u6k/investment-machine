class RenameColumnStockPrices < ActiveRecord::Migration[5.2]
  def change
    rename_column :stock_prices, :opening_price, :open_price
    rename_column :stock_prices, :turnover, :volume
    rename_column :stock_prices, :adjustment_value, :adjusted_close_price

    rename_column :nikkei_averages, :opening_price, :open_price

    rename_column :topixes, :opening_price, :open_price

    rename_column :djia, :opening_price, :open_price
  end
end
