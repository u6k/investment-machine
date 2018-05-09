require 'test_helper'

class TopixTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download csv and get topixes" do
    bucket = Stock._get_s3_bucket

    date_from = Date.new(2018, 2, 1)
    date_to = Date.new(2018, 3, 1)

    keys = Topix.download_topix_csv(date_from, date_to)
    assert_equal "topix_20180201_20180301.csv", keys[:original]
    assert_match /^topix_20180201_20180301\.csv\.bak_[0-9]{14}$/, keys[:backup]
    assert bucket.object(keys[:original]).exists?
    assert bucket.object(keys[:backup]).exists?

    topixes = Topix.get_topixes(keys[:original])

    assert_equal 19, topixes.length
    topixes.each do |topix|
      assert topix.valid?
    end

    assert_equal Date.new(2018, 2, 1), topixes[0].date
    assert_equal "1849.53".to_d, topixes[0].opening_price
    assert_equal "1870.94".to_d, topixes[0].high_price
    assert_equal "1847.01".to_d, topixes[0].low_price
    assert_equal "1870.44".to_d, topixes[0].close_price

    assert_equal 0, Topix.all.length
  end

  test"import topixes and overwrite" do
    topixes = [
      Topix.new(date: Date.parse("2017-09-01"), opening_price: "100.01".to_d, high_price: "200.02".to_d, low_price: "300.03".to_d, close_price: "400.04".to_d),
      Topix.new(date: Date.parse("2017-09-02"), opening_price: "1100.11".to_d, high_price: "1200.12".to_d, low_price: "1300.13".to_d, close_price: "1400.14".to_d),
      Topix.new(date: Date.parse("2017-09-03"), opening_price: "2100.21".to_d, high_price: "2200.22".to_d, low_price: "2300.23".to_d, close_price: "2400.24".to_d)
    ]

    topix_ids = Topix.import(topixes)

    assert_equal 3, topix_ids.length
    topix_ids.each do |topix_id|
      assert Topix.find(topix_id)
    end

    assert_equal 3, Topix.all.length
    topixes.each do |topix|
      topix_actual = Topix.find_by(date: topix.date)

      assert_equal topix.opening_price, topix_actual.opening_price
      assert_equal topix.high_price, topix_actual.high_price
      assert_equal topix.low_price, topix_actual.low_price
      assert_equal topix.close_price, topix_actual.close_price
    end

    topixes[1].opening_price = 10001.01
    topixes[1].high_price = 10002.02
    topixes[1].low_price = 10003.03
    topixes[1].close_price = 10004.04

    topixes << Topix.new(date: Date.parse("2017-09-04"), opening_price: "3100.31".to_d, high_price: "3200.32".to_d, low_price: "3300.33".to_d, close_price: "3400.34".to_d)

    topix_ids = Topix.import(topixes)

    assert_equal 4, topix_ids.length
    topix_ids.each do |topix_id|
      assert Topix.find(topix_id)
    end

    assert_equal 4, Topix.all.length
    topixes.each do |topix|
      topix_actual = Topix.find_by(date: topix.date)

      assert_equal topix.opening_price, topix_actual.opening_price
      assert_equal topix.high_price, topix_actual.high_price
      assert_equal topix.low_price, topix_actual.low_price
      assert_equal topix.close_price, topix_actual.close_price
    end
  end

end
