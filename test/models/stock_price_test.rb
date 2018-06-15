require 'test_helper'

class StockPriceTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download csv and get stock prices" do
    # precondition
    bucket = Stock._get_s3_bucket

    Stock.new(ticker_symbol: "1301", company_name: "foo", market: "hoge").save!

    ticker_symbol = "1301"
    year = 2001

    # execute 1
    result = StockPrice.download_stock_price_csv(ticker_symbol, year)

    # postcondition 1
    data = result[:data]
    stock_prices = result[:stock_prices]

    assert data.length > 0

    assert stock_prices.length > 0
    stock_prices.each do |stock_price|
      assert stock_price.valid?
    end

    assert_equal 1, Stock.all.length
    assert_equal 0, StockPrice.all.length

    # execute 2
    object_keys = StockPrice.put_stock_price_csv(ticker_symbol, year, data)

    stock_price_csv_data = StockPrice.get_stock_price_csv(ticker_symbol, year)

    # postconditions 2
    assert_equal 1, Stock.all.length
    assert_equal 0, StockPrice.all.length

    assert_equal "stock_price_1301_2001.csv", object_keys[:original]
    assert_match /^stock_price_1301_2001\.csv\.bak_[0-9]{8}-[0-9]{6}$/, object_keys[:backup]
    assert bucket.object(object_keys[:original]).exists?
    assert bucket.object(object_keys[:backup]).exists?

    assert_equal data, stock_price_csv_data
  end

  test "download csv, missing only" do
    # precondition
    bucket = Stock._get_s3_bucket
    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)

    Stock.new(ticker_symbol: "1301", company_name: "foo", market: "hoge").save!

    # execute 1
    result = StockPrice.download_stock_price_csv("1301", 2001)
    StockPrice.put_stock_price_csv("1301", 2001, result[:data])

    # postcondition 1
    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)

    # execute 2
    result = StockPrice.download_stock_price_csv("1301", 2001)
    StockPrice.put_stock_price_csv("1301", 2001, result[:data])

    # postcondition 2
    assert_equal 3, Stock._get_s3_objects_size(bucket.objects)

    # execute 3
    result = StockPrice.download_stock_price_csv("1301", 2001, true)

    # postcondition 3
    assert_nil result
    assert_equal 3, Stock._get_s3_objects_size(bucket.objects)
  end

  test "import stock_prices and overwrite" do
    # precondition 1
    stock = Stock.new(ticker_symbol: "1301", company_name: "foo", market: "hoge")
    stock.save!

    stock_prices = [
      StockPrice.new(date: Date.parse("2001-01-01"), opening_price: 100, high_price: 200, low_price: 300, close_price: 400, turnover: 500, adjustment_value: 600, stock: stock),
      StockPrice.new(date: Date.parse("2001-01-02"), opening_price: 1100, high_price: 1200, low_price: 1300, close_price: 1400, turnover: 1500, adjustment_value: 1600, stock: stock),
      StockPrice.new(date: Date.parse("2001-01-03"), opening_price: 2100, high_price: 2200, low_price: 2300, close_price: 2400, turnover: 2500, adjustment_value: 2600, stock: stock)
    ]

    # execute 2
    stock_price_ids = StockPrice.import(stock_prices)

    # postcondition 2
    assert_equal 3, stock_price_ids.length
    stock_price_ids.each do |stock_price_id|
      assert StockPrice.find(stock_price_id)
    end

    assert_equal 3, StockPrice.all.length
    stock_prices.each do |stock_price|
      stock_price_actual = StockPrice.find_by(date: stock_price.date, stock_id: stock.id)

      assert_equal stock_price.opening_price, stock_price_actual.opening_price
      assert_equal stock_price.high_price, stock_price_actual.high_price
      assert_equal stock_price.low_price, stock_price_actual.low_price
      assert_equal stock_price.close_price, stock_price_actual.close_price
      assert_equal stock_price.turnover, stock_price_actual.turnover
      assert_equal stock_price.adjustment_value, stock_price_actual.adjustment_value
    end

    # precondition 2
    stock_prices[1].opening_price = 10001
    stock_prices[1].high_price = 10002
    stock_prices[1].low_price = 10003
    stock_prices[1].close_price = 10004
    stock_prices[1].turnover = 10005
    stock_prices[1].adjustment_value = 10006

    stock_prices << StockPrice.new(date: Date.parse("2001-01-04"), opening_price: 3100, high_price: 3200, low_price: 3300, close_price: 3400, turnover: 3500, adjustment_value: 3600, stock: stock)

    # execute 2
    stock_price_ids = StockPrice.import(stock_prices)

    # postcondition 2
    assert_equal 4, stock_price_ids.length
    stock_price_ids.each do |stock_price_id|
      assert StockPrice.find(stock_price_id)
    end

    assert_equal 4, StockPrice.all.length
    stock_prices.each do |stock_price|
      stock_price_actual = StockPrice.find_by(date: stock_price.date, stock_id: stock.id)

      assert_equal stock_price.opening_price, stock_price_actual.opening_price
      assert_equal stock_price.high_price, stock_price_actual.high_price
      assert_equal stock_price.low_price, stock_price_actual.low_price
      assert_equal stock_price.close_price, stock_price_actual.close_price
      assert_equal stock_price.turnover, stock_price_actual.turnover
      assert_equal stock_price.adjustment_value, stock_price_actual.adjustment_value
    end
  end

  test "download page 1 and get stocks and get stock_prices and import" do
    # execute
    result = Stock.download_index_page
    page_links = result[:page_links]

    result = Stock.download_stock_list_page(page_links[0])
    stocks = result[:stocks]

    Stock.import(stocks)

    result = Stock.download_stock_detail_page(stocks[0].ticker_symbol)
    years = result[:years]

    result = StockPrice.download_stock_price_csv(stocks[0].ticker_symbol, 2018)
    stock_prices = result[:stock_prices]

    # postcondition
    assert_equal 0, StockPrice.all.length

    stock_price_ids = StockPrice.import(stock_prices)

    assert_equal stock_price_ids.length, StockPrice.all.length

    stock_prices.each do |stock_price|
      stock_price_actual = StockPrice.find_by(date: stock_price.date, stock_id: stock_price.stock.id)

      assert_equal stock_price.opening_price, stock_price_actual.opening_price
      assert_equal stock_price.high_price, stock_price_actual.high_price
      assert_equal stock_price.low_price, stock_price_actual.low_price
      assert_equal stock_price.close_price, stock_price_actual.close_price
      assert_equal stock_price.turnover, stock_price_actual.turnover
      assert_equal stock_price.adjustment_value, stock_price_actual.adjustment_value
    end
  end

end
