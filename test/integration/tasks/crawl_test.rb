require 'test_helper'
require 'rake'

class CrawlTest < ActionDispatch::IntegrationTest

  def setup
    Rails.application.load_tasks

    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!

    Stock.all.delete_all
    StockPrice.all.delete_all
  end

  def teardown
    Rake::Task["crawl:download_stocks"].clear
    Rake::Task["crawl:import_stocks"].clear
    Rake::Task["crawl:download_stock_prices"].clear
    Rake::Task["crawl:import_stock_prices"].clear
  end

  test "stocks download and import" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, Stock.all.length

    Rake::Task["crawl:download_stocks"].invoke(false)

    assert Stock._get_s3_objects_size(bucket.objects) > 30
    assert_equal 0, Stock.all.length

    Rake::Task["crawl:import_stocks"].invoke

    assert Stock._get_s3_objects_size(bucket.objects) > 30
    assert Stock.all.length > 3800

    # missing only
    # TODO: not working
    Rake::Task["crawl:download_stocks"].invoke(true)

    assert Stock._get_s3_objects_size(bucket.objects) > 30
    assert Stock.all.length > 3800
  end

  test "stock_prices download and import" do
    bucket = Stock._get_s3_bucket

    Stock.new(ticker_symbol: "1301", company_name: "foo", market: "hoge").save!

    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, StockPrice.all.length

    Rake::Task["crawl:download_stock_prices"].invoke("1301", "all", false)

    assert Stock._get_s3_objects_size(bucket.objects) > 30
    assert_equal 0, StockPrice.all.length

    Rake::Task["crawl:import_stock_prices"].invoke("all", "all")

    assert Stock._get_s3_objects_size(bucket.objects) > 30
    assert StockPrice.all.length > 6000
 
    # missing only
    # TODO: not working
    Rake::Task["crawl:download_stock_prices"].invoke("1301", "all", true)

    assert Stock._get_s3_objects_size(bucket.objects) > 30
    assert StockPrice.all.length > 6000
 end

end
