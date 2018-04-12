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

  def _get_objects_size(objects)
    count = 0
    objects.each { |obj| count += 1 }

    count
  end

  test "stocks download and import" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, _get_objects_size(bucket.objects)
    assert_equal 0, Stock.all.length

    Rake::Task["crawl:download_stocks"].invoke

    assert _get_objects_size(bucket.objects) > 30
    assert_equal 0, Stock.all.length

    Rake::Task["crawl:import_stocks"].invoke

    assert _get_objects_size(bucket.objects) > 30
    assert Stock.all.length > 3800
  end

  test "stocks download and import missing only" do
    # TODO
  end

  test "stock_prices download and import" do
    bucket = Stock._get_s3_bucket

    Stock.new(ticker_symbol: "1301", company_name: "foo", market: "hoge").save!

    assert_equal 0, _get_objects_size(bucket.objects)
    assert_equal 0, StockPrice.all.length

    Rake::Task["crawl:download_stock_prices"].invoke("1301", "all")

    assert _get_objects_size(bucket.objects) > 30
    assert_equal 0, StockPrice.all.length

    Rake::Task["crawl:import_stock_prices"].invoke("all", "all")

    assert _get_objects_size(bucket.objects) > 30
    assert StockPrice.all.length > 6000
  end

  test "stock_prices download and import missing only" do
    # TODO
  end

end
