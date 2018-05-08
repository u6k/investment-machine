require 'test_helper'

class NikkeiAverageTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download html and get nikkei averages" do
    bucket = Stock._get_s3_bucket

    year = 2017
    month = 9

    keys = NikkeiAverage.download_nikkei_average_html(year, month)
    assert_equal "nikkei_average_2017_11.html", keys[:original]
    assert_match /^nikkei_average_2017_11\.html\.bak_[0-9]{14}$/, keys[:baxkup]
    assert bucket.object(keys[:original]).exists?
    assert bucket.object(keys[:backup]).exists?

    nikkei_averages = NikkeiAverage.get_nikkei_average(keys[:original])

    assert nikkei_averages.length > 0
    nikkei_averages.each do |nikkei_average|
      assert nikkei_average.valid?
    end

    assert_equal 0, NikkeiAverage.all.length
  end

  test "download html, missing only" do
    bucket = Stock._get_s3_bucket

    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)

    NikkeiAverage.download_nikkei_average_html(2017, 9)
    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)

    NikkeiAverage.download_nikkei_average_html(2017, 9)
    assert_equal 3, Stock._get_s3_objects_size(bucket.objects)

    NikkeiAverage.download_nikkei_average_html(2017, 9, true)
    assert_equal 3, Stock._get_s3_objects_size(bucket.objects)
  end

  test "import nikkei_averages and overwrite" do
    nikkei_averages = [
      NikkeiAverage.new(date: Date.parse("2017-09-01"), opening_price: "100.01".to_d, high_price: "200.02".to_d, low_price: "300.03".to_d, close_price: "400.04".to_d),
      NikkeiAverage.new(date: Date.parse("2017-09-02"), opening_price: "1100.11".to_d, high_price: "1200.12".to_d, low_price: "1300.13".to_d, close_price: "1400.14".to_d),
      NikkeiAverage.new(date: Date.parse("2017-09-01"), opening_price: "2100.21".to_d, high_price: "2200.22".to_d, low_price: "2300.23".to_d, close_price: "2400.24".to_d)
    ]

    nikkei_average_ids = NikkeiAverage.import(nikkei_averages)

    assert_equal 3, nikkei_average_ids.length
    nikkei_average_ids.each do |nikkei_average_id|
      assert NikkeiAverage.find(nikkei_average_id)
    end

    assert_equal 3, NikkeiAverage.all.length
    nikkei_averages.each do |nikkei_average|
      nikkei_average_actual = NikkeiAverage.find_by(date: nikkei_average.date)

      assert_equal nikkei_average.opening_price, nikkei_average_actual.opening_price
      assert_equal nikkei_average.high_price, nikkei_average_actual.high_price
      assert_equal nikkei_average.low_price, nikkei_average_actual.low_price
      assert_equal nikkei_average.close_price, nikkei_average_actual.close_price
    end

    nikkei_averages[1].opening_price = 10001.01
    nikkei_averages[1].high_price = 10002.02
    nikkei_averages[1].low_price = 10003.03
    nikkei_averages[1].close_price = 10004.04

    nikkei_averages << NikkeiAverage.new(date: Date.parse("2017-09-04"), opening_price: "3100.31".to_d, high_price: "3200.32".to_d, low_price: "3300.33".to_d, close_price: "3400.34".to_d)

    nikkei_average_ids = NikkeiAverage.import(nikkei_averages)

    assert_equal 4, nikkei_average_ids.length
    nikkei_average_ids.each do |nikkei_average_id|
      assert NikkeiAverage.find(nikkei_average_id)
    end

    assert_equal 4, NikkeiAverage.all.length
    nikkei_averages.each do |nikkei_average|
      nikkei_average_actual = NikkeiAverage.find_by(date: nikkei_average.date)

      assert_equal nikkei_average.opening_price, nikkei_average_actual.opening_price
      assert_equal nikkei_average.high_price, nikkei_average_actual.high_price
      assert_equal nikkei_average.low_price, nikkei_average_actual.low_price
      assert_equal nikkei_average.close_price, nikkei_average_actual.close_price
    end
  end

end
