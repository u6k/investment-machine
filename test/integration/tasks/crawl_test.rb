require 'test_helper'

class CrawlTest < ActionDispatch::IntegrationTest

  def setup
    Myapp::Application.load_tasks
  end

  test "test" do
    # TODO
    Rake::Task["crawl:hello"].invoke(ticker_symbol: "1002", year: 2018)
  end

  test "get all stocks" do
    # TODO
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
