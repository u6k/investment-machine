require 'test_helper'

class StockTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download index page and get page links" do
    # execute 1
    result = Stock.download_index_page

    # postcondition 1
    data = result[:data]
    page_links = result[:page_links]

    assert data.length > 0

    assert page_links.length > 0
    page_links.each do |l|
      assert_match /^\?page=/, l
    end

    assert_equal 0, Stock.all.length

    bucket = Stock._get_s3_bucket
    assert_not bucket.object("stock_list_index.html").exists?

    # execute 2
    object_keys = Stock.put_index_page(bucket, result[:data])

    # postcondition 2
    assert_equal 0, Stock.all.length

    assert_equal "stock_list_index.html", object_keys[:original]
    assert_match /^stock_list_index\.html\.bak_[0-9]{8}-[0-9]{6}/, object_keys[:backup]
    assert bucket.object(object_keys[:original]).exists?
    assert bucket.object(object_keys[:backup]).exists?
  end

  test "download page 1 and get stocks" do
    # execute 1
    result = Stock.download_stock_list_page("?page=1")

    # postcondition 1
    data = result[:data]
    stocks = result[:stocks]

    assert data.length > 0

    assert stocks.length > 0
    stocks.each do |stock|
      assert stock.valid?
    end

    assert_equal 0, Stock.all.length

    bucket = Stock._get_s3_bucket
    assert_not bucket.object("stock_list_?page=1.html").exists?

    # execute 2
    object_keys = Stock.put_stock_list_page(bucket, "?page=1", result[:data])

    # postcondition 2
    assert_equal 0, Stock.all.length

    assert_equal "stock_list_?page=1.html", object_keys[:original]
    assert_match /^stock_list_\?page=1\.html\.bak_[0-9]{8}-[0-9]{6}/, object_keys[:backup]
    assert bucket.object(object_keys[:original]).exists?
    assert bucket.object(object_keys[:backup]).exists?
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
    # precondition
    assert_equal 0, Stock.all.length

    # execute
    download_index_page_result = Stock.download_index_page

    download_stock_list_page_result = Stock.download_stock_list_page(download_index_page_result[:page_links][0])
    stock_ids = Stock.import(download_stock_list_page_result[:stocks])

    # postcondition
    assert_equal stock_ids.length, Stock.all.length

    stocks.each do |stock|
      stock_actual = Stock.find_by(ticker_symbol: stock.ticker_symbol)

      assert_equal stock.company_name, stock_actual.company_name
      assert_equal stock.market, stock_actual.market
    end
  end

  test "download stock detail page and get years" do
    bucket = Stock._get_s3_bucket

    keys = Stock.download_stock_detail_page("1301")
    assert_equal "stock_detail_1301.html", keys[:original]
    assert_match /^stock_detail_1301\.html\.bak_[0-9]{14}/, keys[:backup]
    assert bucket.object(keys[:original]).exists?
    assert bucket.object(keys[:backup]).exists?

    years = Stock.get_years(keys[:original])

    assert_equal 36, years.length
    (1983..2018).each do |year|
      assert_includes years, year
    end
  end

  test "download stock detail page, missing only" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)

    Stock.download_stock_detail_page("1301")
    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)

    Stock.download_stock_detail_page("1301")
    assert_equal 3, Stock._get_s3_objects_size(bucket.objects)

    Stock.download_stock_detail_page("1301", true)
    assert_equal 3, Stock._get_s3_objects_size(bucket.objects)
  end

end
