require 'test_helper'
require 'rake'

class CrawlTest < ActionDispatch::IntegrationTest

  def setup
    Rails.application.load_tasks

    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!

    Stock.all.delete_all
  end

  def teardown
    Rake::Task["crawl:download_stocks"].clear
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
    # TODO
  end

  test "stock_prices download and import missing only" do
    # TODO
  end

end
