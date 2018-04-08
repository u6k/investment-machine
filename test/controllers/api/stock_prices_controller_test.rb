require 'test_helper'

class StockPricesControllerTest < ActionDispatch::IntegrationTest

  def setup
    Stock.new(ticker_symbol: "1001", company_name: "foo", market: "hoge").save!
    Stock.new(ticker_symbol: "1002", company_name: "bar", market: "hoge").save!
    Stock.new(ticker_symbol: "1003", company_name: "boo", market: "hoge").save!

    StockPrice.new(date: Date.parse("2001-01-01"), opening_price: 100101, high_price: 100102, low_price: 100103, close_price: 100104, turnover: 100105, adjustment_value: 100106, stock: Stock.all[0]).save!
    StockPrice.new(date: Date.parse("2002-01-01"), opening_price: 100201, high_price: 100202, low_price: 100203, close_price: 100204, turnover: 100205, adjustment_value: 100206, stock: Stock.all[1]).save!
    StockPrice.new(date: Date.parse("2002-01-02"), opening_price: 100212, high_price: 100212, low_price: 100213, close_price: 100214, turnover: 100215, adjustment_value: 100216, stock: Stock.all[1]).save!
    StockPrice.new(date: Date.parse("2002-01-03"), opening_price: 100221, high_price: 100222, low_price: 100223, close_price: 100224, turnover: 100225, adjustment_value: 100226, stock: Stock.all[1]).save!
    StockPrice.new(date: Date.parse("2003-01-01"), opening_price: 100301, high_price: 100302, low_price: 100303, close_price: 100304, turnover: 100305, adjustment_value: 100306, stock: Stock.all[2]).save!
  end

  test "get all stock_prices" do
    get api_stock_stock_prices_url(stock_id: "1002")
    assert_response :success

    stock_prices = JSON.parse(response.body)

    assert_equal 3, stock_prices.length

    p stock_prices

    stock_prices.each do |stock_price|
      assert_equal 7, stock_price.length
      assert_match /^\d{4}-\d{2}-\d{2}$/, stock_price["date"]
      assert stock_price["opening_price"].integer?
      assert stock_price["high_price"].integer?
      assert stock_price["low_price"].integer?
      assert stock_price["close_price"].integer?
      assert stock_price["turnover"].integer?
      assert stock_price["adjustment_value"].integer?
    end
  end

end
