require 'test_helper'

class StockPriceTest < ActiveSupport::TestCase

  test "download years for stock" do
    transaction_id = Stock._generate_transaction_id
    ticker_symbol = "1301"

    years = StockPrice.download_years(ticker_symbol, transaction_id)

    assert_equal 36, years.length
    (1983..2018).each do |year|
      assert_includes years, year
    end

    bucket = Stock._get_s3_bucket
    assert bucket.object("#{transaction_id}/stock_detail_1301.html").exists?
  end

  test "download csv with ticker symbol and year" do
    transaction_id = Stock._generate_transaction_id
    ticker_symbol = "1301"
    year = 2001

    stock_prices_data = StockPrice.download_stock_prices(ticker_symbol, year, transaction_id)

    expected_date_min = Date.new(2001, 1, 1)
    expected_date_max = Date.new(2002, 1, 1)

    assert stock_prices_data.length > 0
    stock_prices_data.each do |stock_price|
      assert stock_price[:date].date?
      assert stock_price[:date] >= expected_date_min && stock_price[:date] < expected_date_max
      assert stock_price[:opening_price].integer?
      assert stock_price[:high_price].integer?
      assert stock_price[:low_price].integer?
      assert stock_price[:close_price].integer?
      assert stock_price[:turnover].integer?
      assert stock_price[:adjustment_value].integer?
    end

    bucket = Stock._get_s3_bucket
    assert bucket.object("#{transaction_id}/stock_price_1301_2001.csv").exists?
  end

end
