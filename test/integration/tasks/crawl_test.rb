require 'test_helper'
require 'minitest/autorun'

class CrawlTest < ActionDispatch::IntegrationTest

  test "hello" do
    mock = MiniTest::Mock.new
    mock.expect :call, "foo", ["xxx"]

    Stock.stub :download_index_page, mock do
      key = Stock.download_index_page("xxx")
      assert_equal "foo", key
    end
  end

  test "get all stocks" do
    assert_equal 0, Stock.all.length
    assert_equal 0, StockPrice.all.length

    Myapp::Application.load_tasks
    Rake::Task["crawl:stocks"].invoke

    assert Stock.all.length > 3000
    assert_equal 0, StockPrice.all.length
  end

  test "get stock_prices ticker_symbol=1301, year=2018" do
    # TODO
  end

  test "get stock_prices ticker_symbol=1301, year=nil" do
    # TODO
  end

  test "get stock_prices ticker_symbol=nil, year=2018" do
    # TODO
  end

  test "get stock_prices ticker_symbol=nil, year=nil" do
    # TODO
  end

end
