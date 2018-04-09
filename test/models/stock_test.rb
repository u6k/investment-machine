require 'test_helper'

class StockTest < ActiveSupport::TestCase

  test "download index page and get page links" do
    transaction_id = Stock._generate_transaction_id

    index_page_object_key = Stock.download_index_page(transaction_id)
    page_links = Stock.get_page_links(index_page_object_key)

    assert page_links.length > 0
    page_links.each do |l|
      assert l.match(/^\?page=/)
    end

    assert_equal 0, Stock.all.length

    bucket = Stock._get_s3_bucket
    assert bucket.object(index_page_object_key).exists?
  end

  test "download page 1 and get stocks" do
    transaction_id = Stock._generate_transaction_id

    index_page_object_key = Stock.download_index_page(transaction_id)
    page_links = Stock.get_page_links(index_page_object_key)

    stock_list_page_object_key = Stock.download_stock_list_page(transaction_id, page_links[0])
    stocks = Stock.get_stocks(stock_list_page_object_key)

    assert stocks.length > 0
    stocks.each do |stock|
      assert stock.valid?
    end

    assert_equal 0, Stock.all.length
  end

  test "import stocks" do
    stocks = [
      Stock.new(ticker_symbol: "1001", company_name: "foo", market: "hoge"),
      Stock.new(ticker_symbol: "1002", company_name: "bar", market: "hoge"),
      Stock.new(ticker_symbol: "1003", company_name: "boo", market: "hoge")
    ]

    stock_ids = Stock.import(stocks)

    assert_equal 3, stock_ids.length
    stock_ids.each do |stock_id|
      assert Stock.find(stock_id)
    end

    assert_equal 3, Stock.all.length
    stocks.each do |stock|
      stock_actual = Stock.find_by(ticker_symbol: stock.ticker_symbol)

      assert_equal stock.company_name, stock_actual.company_name
      assert_equal stock.market, stock_actual.market
    end
  end

  test "import stocks and overwrite" do
    stocks = [
      Stock.new(ticker_symbol: "1001", company_name: "foo", market: "hoge"),
      Stock.new(ticker_symbol: "1002", company_name: "bar", market: "hoge"),
      Stock.new(ticker_symbol: "1003", company_name: "boo", market: "hoge")
    ]

    stock_ids = Stock.import(stocks)

    assert_equal 3, stock_ids.length
    assert_equal 3, Stock.all.length
    stocks.each do |stock|
      stock_actual = Stock.find_by(ticker_symbol: stock.ticker_symbol)

      assert_equal stock.company_name, stock_actual.company_name
      assert_equal stock.market, stock_actual.market
    end

    stocks[1].company_name = "foo bar"

    stocks << Stock.new(ticker_symbol: "1004", company_name: "hoge hoge", market: "hoge")

    stock_ids = Stock.import(stocks)

    assert_equal 4, stock_ids.length
    assert_equal 4, Stock.all.length
    stocks.each do |stock|
      stock_actual = Stock.find_by(ticker_symbol: stock.ticker_symbol)

      assert_equal stock.company_name, stock_actual.company_name
      assert_equal stock.market, stock_actual.market
    end
  end

  test "download page 1 and get stocks and import stocks" do
    transaction_id = Stock._generate_transaction_id

    index_page_object_key = Stock.download_index_page(transaction_id)
    page_links = Stock.get_page_links(index_page_object_key)

    stock_list_page_object_key = Stock.download_stock_list_page(transaction_id, page_links[0])
    stocks = Stock.get_stocks(stock_list_page_object_key)

    assert_equal 0, Stock.all.length

    stock_ids = Stock.import(stocks)

    assert_equal stock_ids.length, Stock.all.length

    stocks.each do |stock|
      stock_actual = Stock.find_by(ticker_symbol: stock.ticker_symbol)

      assert_equal stock.company_name, stock_actual.company_name
      assert_equal stock.market, stock_actual.market
    end
  end

  test "download stock detail page and get years" do
    transaction_id = Stock._generate_transaction_id

    stock_detail_page_object_key = Stock.download_stock_detail_page(transaction_id, "1301")
    years = Stock.get_years(stock_detail_page_object_key)

    assert_equal 36, years.length
    (1983..2018).each do |year|
      assert_includes years, year
    end
  end

end
