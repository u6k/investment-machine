require 'test_helper'

class StocksControllerTest < ActionDispatch::IntegrationTest

  def setup
    Stock.new(ticker_symbol: "1001", company_name: "foo", market: "hoge").save!
    Stock.new(ticker_symbol: "1002", company_name: "bar", market: "hoge").save!
    Stock.new(ticker_symbol: "1003", company_name: "boo", market: "hoge").save!
  end

  test "get all stocks" do
    get api_stocks_url
    assert_response :success

    stocks = JSON.parse(response.body)

    assert_equal 3, stocks.length

    stocks.each do |stock|
      assert_equal 3, stock.length
      assert_match /^\d{4}$/, stock["ticker_symbol"]
      assert stock["company_name"].length > 0
      assert stock["market"].length > 0
    end
  end

  test "get stock" do
    get api_stock_url(id: "1002")
    assert_response :success

    stock = JSON.parse(response.body)

    assert_equal 3, stock.length
    assert_match /^\d{4}$/, stock["ticker_symbol"]
    assert stock["company_name"].length > 0
    assert stock["market"].length > 0
  end

end
