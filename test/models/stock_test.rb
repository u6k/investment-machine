require 'test_helper'

class StockTest < ActiveSupport::TestCase
  
  test "save stock" do
    assert_equal 0, Stock.all.length

    stock = Stock.new
    assert stock.save

    assert_equal 1, Stock.all.length
  end

end
