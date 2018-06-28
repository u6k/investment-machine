require 'test_helper'
require 'rake'

class CrawlTest < ActionDispatch::IntegrationTest

  def setup
    Rails.application.load_tasks

    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!

    Stock.all.delete_all
    StockPrice.all.delete_all
    NikkeiAverage.all.delete_all
    DowJonesIndustrialAverage.all.delete_all
    WertpapierReport.all.delete_all
  end

  def teardown
    Rake::Task["crawl:download_stocks"].clear
    Rake::Task["crawl:import_stocks"].clear
    Rake::Task["crawl:download_stock_prices"].clear
    Rake::Task["crawl:import_stock_prices"].clear
    Rake::Task["crawl:download_nikkei_averages"].clear
    Rake::Task["crawl:import_nikkei_averages"].clear
    Rake::Task["crawl:download_topixes"].clear
    Rake::Task["crawl:import_topixes"].clear
    Rake::Task["crawl:download_dow_jones_industrial_averages"].clear
    Rake::Task["crawl:import_dow_jones_industrial_averages"].clear
    Rake::Task["crawl:download_wertpapier_report_feeds"].clear
    Rake::Task["crawl:import_wertpapier_report_feeds"].clear
    Rake::Task["crawl:download_wertpapier_report_zips"].clear
  end

  test "stocks download and import" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, Stock.all.length

    Rake::Task["crawl:download_stocks"].invoke

    assert Stock._get_s3_objects_size(bucket.objects) > 30
    assert_equal 0, Stock.all.length

    Rake::Task["crawl:import_stocks"].invoke

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

  test "nikkei averages download and import" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, NikkeiAverage.all.length

    Rake::Task["crawl:download_nikkei_averages"].invoke(2017)

    assert_equal 24, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, NikkeiAverage.all.length

    Rake::Task["crawl:import_nikkei_averages"].invoke(2017)

    assert_equal 24, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 247, NikkeiAverage.all.length
  end

  test "topixes download and import" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, Topix.all.length

    Rake::Task["crawl:download_topixes"].invoke(2017)

    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, Topix.all.length

    Rake::Task["crawl:import_topixes"].invoke(2017)

    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 247, Topix.all.length
  end

  test "dow jones industrial averages download and import" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, DowJonesIndustrialAverage.all.length

    Rake::Task["crawl:download_dow_jones_industrial_averages"].invoke(2017)

    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, DowJonesIndustrialAverage.all.length

    Rake::Task["crawl:import_dow_jones_industrial_averages"].invoke(2017)

    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 251, DowJonesIndustrialAverage.all.length
  end

  test "download and import wertpapier reports - single" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, WertpapierReport.all.length

    Rake::Task["crawl:download_wertpapier_report_feeds"].invoke("1301")

    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 0, WertpapierReport.all.length

    Rake::Task["crawl:import_wertpapier_report_feeds"].invoke("1301")

    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 62, WertpapierReport.all.length

    Rake::Task["crawl:download_wertpapier_report_zips"].invoke("1301")

    assert_equal 126, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 62, WertpapierReport.all.length

    Rake::Task["crawl:download_wertpapier_report_zips"].invoke("1301", true)

    assert_equal 126, Stock._get_s3_objects_size(bucket.objects)
    assert_equal 62, WertpapierReport.all.length
  end

end

