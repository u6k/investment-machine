require 'test_helper'

class StockPriceTest < ActiveSupport::TestCase

  test "save stock_price" do
    assert_equal 0, Stock.all.length
    assert_equal 0, StockPrice.all.length

    stock = Stock.new

    stock_price = StockPrice.new
    stock_price.stock = stock
    assert stock_price.save

    stock_price = StockPrice.new
    stock_price.stock = stock
    assert stock_price.save

    assert_equal 1, Stock.all.length
    assert_equal 2, StockPrice.all.length
  end

end
