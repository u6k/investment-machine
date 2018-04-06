require 'test_helper'

class StockTest < ActiveSupport::TestCase

  test "download page links" do
    transaction_id = Stock._generate_transaction_id

    page_links = Stock.download_page_links(transaction_id)
    sleep(1)

    assert page_links.length > 0
    page_links.each do |l|
      assert l.match(/^\?page=/)
    end

    assert_equal 0, Stock.all.length

    bucket = Stock._get_s3_bucket
    assert bucket.object("#{transaction_id}/index.html").exists?
  end

  test "download stocks" do
    transaction_id = Stock._generate_transaction_id

    page_links = Stock.download_page_links(transaction_id)
    sleep(1)

    stocks = Stock.download_stocks(page_links[0], transaction_id)
    sleep(1)

    assert stocks.length > 0
    stocks.each do |s|
      assert s[:ticker_symbol].match(/^[0-9]{4}$/)
      assert_not s[:company_name].empty?
    end

    assert_equal 0, Stock.all.length

    bucket = Stock._get_s3_bucket
    assert bucket.object("#{transaction_id}/index.html").exists?
    assert bucket.object("#{transaction_id}/stock_list_#{page_links[0]}.html").exists?
  end

  test "import stock" do
    stock_data = [
      { ticker_symbol: "1001", company_name: "foo" },
      { ticker_symbol: "1002", company_name: "bar" },
      { ticker_symbol: "1003", company_name: "boo" }
    ]

    stocks = Stock.import(stock_data)
    assert_equal 3, stocks.length
  end

  test "overwrite stock" do
    stock_data = [
      { ticker_symbol: "1001", company_name: "foo" },
      { ticker_symbol: "1002", company_name: "bar" },
      { ticker_symbol: "1003", company_name: "boo" }
    ]

    stocks = Stock.import(stock_data)
    assert_equal 3, stocks.length
 
    stock_data = [
      { ticker_symbol: "1002", company_name: "hoge" }
    ]

    stocks = Stock.import(stock_data)
    assert_equal 1, stocks.length

    assert_equal 3, Stock.all.length
    assert_equal "foo" , Stock.find_by(ticker_symbol: "1001").company_name
    assert_equal "hoge", Stock.find_by(ticker_symbol: "1002").company_name
    assert_equal "boo" , Stock.find_by(ticker_symbol: "1003").company_name
  end

  test "download and import stocks" do
    transaction_id = Stock._generate_transaction_id

    page_links = Stock.download_page_links(transaction_id)
    sleep(1)
    stocks_data = Stock.download_stocks(page_links[0], transaction_id)
    sleep(1)
    stocks = Stock.import(stocks_data)

    assert stocks_data.length > 30
    assert_equal stocks_data.length, stocks.length

    assert_equal stocks.length, Stock.all.length

    stocks.each do |s|
      stock_actual = Stock.find_by(ticker_symbol: s.ticker_symbol)
      assert_equal s.company_name, stock_actual.company_name
    end

    bucket = Stock._get_s3_bucket
    assert bucket.object("#{transaction_id}/index.html").exists?
    assert bucket.object("#{transaction_id}/stock_list_#{page_links[0]}.html").exists?
  end

end
