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
      assert stock_price[:date].instance_of?(Date)
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

  test "import stock_price data" do
    Stock.new(ticker_symbol: "1301", company_name: "foo").save!

    stock_prices_data = []

    stock_prices_data << {
      date: Date.parse("2001-01-01"),
      opening_price: 100,
      high_price: 200,
      low_price: 300,
      close_price: 400,
      turnover: 500,
      adjustment_value: 600
    }
    stock_prices_data << {
      date: Date.parse("2001-01-02"),
      opening_price: 1100,
      high_price: 1200,
      low_price: 1300,
      close_price: 1400,
      turnover: 1500,
      adjustment_value: 1600
    }
    stock_prices_data << {
      date: Date.parse("2001-01-03"),
      opening_price: 2100,
      high_price: 2200,
      low_price: 2300,
      close_price: 2400,
      turnover: 2500,
      adjustment_value: 2600
    }

    stock_price_ids = StockPrice.import("1301", stock_prices_data)
    assert_equal 3, stock_price_ids.length

    stock_price_ids.each do |stock_price_id|
      assert StockPrice.find(stock_price_id)
    end

    stock_prices = StockPrice.all
    assert_equal 3, stock_prices.length

    stock_prices_data.each do |d|
      stock_price = StockPrice.find_by(date: d[:date])

      assert_equal stock_price.opening_price, d[:opening_price]
      assert_equal stock_price.high_price, d[:high_price]
      assert_equal stock_price.low_price, d[:low_price]
      assert_equal stock_price.close_price, d[:close_price]
      assert_equal stock_price.turnover, d[:turnover]
      assert_equal stock_price.adjustment_value, d[:adjustment_value]
    end

    stock_prices_data[1][:opening_price] = 10001
    stock_prices_data[1][:high_price] = 10002
    stock_prices_data[1][:low_price] = 10003
    stock_prices_data[1][:close_price] = 10004
    stock_prices_data[1][:turnover] = 10005
    stock_prices_data[1][:adjustment_value] = 10006

    stock_prices_data << {
      date: Date.parse("2001-01-04"),
      opening_price: 3100,
      high_price: 3200,
      low_price: 3300,
      close_price: 3400,
      turnover: 3500,
      adjustment_value: 3600
    }

    stock_price_ids = StockPrice.import("1301", stock_prices_data)
    assert_equal 4, stock_price_ids.length

    stock_price_ids.each do |stock_price_id|
      assert StockPrice.find(stock_price_id)
    end

    stock_prices = StockPrice.all
    assert_equal 4, stock_prices.length

    stock_prices_data.each do |d|
      stock_price = StockPrice.find_by(date: d[:date])

      assert_equal stock_price.opening_price, d[:opening_price]
      assert_equal stock_price.high_price, d[:high_price]
      assert_equal stock_price.low_price, d[:low_price]
      assert_equal stock_price.close_price, d[:close_price]
      assert_equal stock_price.turnover, d[:turnover]
      assert_equal stock_price.adjustment_value, d[:adjustment_value]
    end
  end

  test "download csv and import" do
    transaction_id = Stock._generate_transaction_id

    page_links = Stock.download_page_links(transaction_id)
    sleep(1)
    stocks_data = Stock.download_stocks(page_links[0], transaction_id)
    stocks = Stock.import(stocks_data)
    sleep(1)

    assert Stock.all.length > 0

    stock = Stock.first
    ticker_symbol = stock.ticker_symbol
    year = 2018

    stock_prices_data = StockPrice.download_stock_prices(ticker_symbol, year, transaction_id)
    stock_price_ids = StockPrice.import(ticker_symbol, stock_prices_data)

    assert stock_price_ids.length > 0

    stock_prices = StockPrice.where("stock_id = :stock_id", stock_id: stock.id)

    assert stock_prices.length > 0
  end

end
