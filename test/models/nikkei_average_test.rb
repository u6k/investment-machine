require 'test_helper'

class NikkeiAverageTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download html and get nikkei averages" do
    # precondition
    bucket = Stock._get_s3_bucket

    year = 2017
    month = 9

    # execute 1
    result = NikkeiAverage.download_nikkei_average_html(year, month)

    # postcondition 1
    data = result[:data]
    nikkei_averages = result[:nikkei_averages]

    assert data.length > 0

    assert_equal 20, nikkei_averages.length
    nikkei_averages.each do |nikkei_average|
      assert nikkei_average.valid?
    end

    assert_equal Date.parse('2017-09-01'), nikkei_averages[0].date
    assert_equal "19733.57".to_d, nikkei_averages[0].opening_price
    assert_equal "19735.96".to_d, nikkei_averages[0].high_price
    assert_equal "19620.07".to_d, nikkei_averages[0].low_price
    assert_equal "19691.47".to_d, nikkei_averages[0].close_price

    assert_equal 0, NikkeiAverage.all.length

    # execute 2
    object_keys = NikkeiAverage.put_nikkei_average_html(year, month, data)

    nikkei_average_html_data = NikkeiAverage.get_nikkei_average_html(year, month)

    # postcondition 2
    assert_equal 0, NikkeiAverage.all.length

    assert_equal "nikkei_average_2017_09.html", object_keys[:original]
    assert_match /^nikkei_average_2017_09\.html\.bak_[0-9]{8}-[0-9]{6}$/, object_keys[:backup]
    assert bucket.object(object_keys[:original]).exists?
    assert bucket.object(object_keys[:backup]).exists?

    assert_equal data, nikkei_average_html_data
  end

  test "download html, missing only" do
    # precondition
    bucket = Stock._get_s3_bucket
    assert_equal 0, Stock._get_s3_objects_size(bucket.objects)

    # execute 1
    result = NikkeiAverage.download_nikkei_average_html(2017, 9)
    NikkeiAverage.put_nikkei_average_html(2017, 9, result[:data])

    # postcondition 1
    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)

    # execute 2
    result = NikkeiAverage.download_nikkei_average_html(2017, 9)
    NikkeiAverage.put_nikkei_average_html(2017, 9, result[:data])

    # postcondition 2
    assert_equal 3, Stock._get_s3_objects_size(bucket.objects)

    # execute 3
    result = NikkeiAverage.download_nikkei_average_html(2017, 9, true)

    # postcondition 3
    assert_nil result
  end

  test "import nikkei_averages and overwrite" do
    # precondition 1
    nikkei_averages = [
      NikkeiAverage.new(date: Date.parse("2017-09-01"), opening_price: "100.01".to_d, high_price: "200.02".to_d, low_price: "300.03".to_d, close_price: "400.04".to_d),
      NikkeiAverage.new(date: Date.parse("2017-09-02"), opening_price: "1100.11".to_d, high_price: "1200.12".to_d, low_price: "1300.13".to_d, close_price: "1400.14".to_d),
      NikkeiAverage.new(date: Date.parse("2017-09-03"), opening_price: "2100.21".to_d, high_price: "2200.22".to_d, low_price: "2300.23".to_d, close_price: "2400.24".to_d)
    ]

    # execute 1
    nikkei_average_ids = NikkeiAverage.import(nikkei_averages)

    # postcondition 1
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

    # precondition 2
    nikkei_averages[1].opening_price = 10001.01
    nikkei_averages[1].high_price = 10002.02
    nikkei_averages[1].low_price = 10003.03
    nikkei_averages[1].close_price = 10004.04

    nikkei_averages << NikkeiAverage.new(date: Date.parse("2017-09-04"), opening_price: "3100.31".to_d, high_price: "3200.32".to_d, low_price: "3300.33".to_d, close_price: "3400.34".to_d)

    # execute 2
    nikkei_average_ids = NikkeiAverage.import(nikkei_averages)

    # postcondition 2
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
