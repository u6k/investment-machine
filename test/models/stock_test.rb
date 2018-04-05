require 'test_helper'

class StockTest < ActiveSupport::TestCase
  
  test "save stock" do
    assert_equal 0, Stock.all.length

    stock = Stock.new
    assert stock.save

    assert_equal 1, Stock.all.length
  end

  test "download page links" do
    page_links = Stock.download_page_links

    assert page_links.length > 0
    page_links.each do |l|
      assert l.match(/^\?page=/)
    end
  end

end
