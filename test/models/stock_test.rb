require 'test_helper'

class StockTest < ActiveSupport::TestCase
  
  test "download page links" do
    page_links = Stock.download_page_links

    assert page_links.length > 0
    page_links.each do |l|
      assert l.match(/^\?page=/)
    end

    assert_equal 0, Stock.all.length
  end

  test "download stocks" do
    page_links = Stock.download_page_links
    sleep(1)

    stocks = Stock.download_stocks(page_links[0])

    assert stocks.length > 0
    stocks.each do |s|
      assert s[:code].match(/^[0-9]{4}$/)
      assert_not s[:name].empty?
    end

    assert_equal 0, Stock.all.length
  end

end
