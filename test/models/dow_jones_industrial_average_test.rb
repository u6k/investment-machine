require 'test_helper'

class DowJonesIndustrialAverageTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download csv and get djia" do
    bucket = Stock._get_s3_bucket

    date_from = Date.new(2018, 2, 1)
    date_to = Date.new(2018, 3, 1)

    keys = DowJonesIndustrialAverage.download_djia_csv(date_from, date_to)
    assert_equal "djia_20180201_20180301.csv", keys[:original]
    assert_match /^djia_20180201_20180301\.csv\.bak_[0-9]{14}$/, keys[:backup]
    assert bucket.object(keys[:original]).exists?
    assert bucket.object(keys[:backup]).exists?

    djias = DowJonesIndustrialAverage.get_djias(keys[:original])

    assert_equal 19, djias.length
    djias.each do |djia|
      assert djia.valid?
    end

    assert_equal Date.new(2018, 2, 1), djias[18].date
    assert_equal "26083.04".to_d, djias[18].opening_price
    assert_equal "26306.70".to_d, djias[18].high_price
    assert_equal "26014.44".to_d, djias[18].low_price
    assert_equal "26186.71".to_d, djias[18].close_price

    assert_equal 0, DowJonesIndustrialAverage.all.length
  end

  test"import djias and overwrite" do
    djias = [
      DowJonesIndustrialAverage.new(date: Date.parse("2017-09-01"), opening_price: "100.01".to_d, high_price: "200.02".to_d, low_price: "300.03".to_d, close_price: "400.04".to_d),
      DowJonesIndustrialAverage.new(date: Date.parse("2017-09-02"), opening_price: "1100.11".to_d, high_price: "1200.12".to_d, low_price: "1300.13".to_d, close_price: "1400.14".to_d),
      DowJonesIndustrialAverage.new(date: Date.parse("2017-09-03"), opening_price: "2100.21".to_d, high_price: "2200.22".to_d, low_price: "2300.23".to_d, close_price: "2400.24".to_d)
    ]

    djia_ids = DowJonesIndustrialAverage.import(djias)

    assert_equal 3, djia_ids.length
    djia_ids.each do |djia_id|
      assert DowJonesIndustrialAverage.find(djia_id)
    end

    assert_equal 3, DowJonesIndustrialAverage.all.length
    djias.each do |djia|
      djia_actual = DowJonesIndustrialAverage.find_by(date: djia.date)

      assert_equal djia.opening_price, djia_actual.opening_price
      assert_equal djia.high_price, djia_actual.high_price
      assert_equal djia.low_price, djia_actual.low_price
      assert_equal djia.close_price, djia_actual.close_price
    end

    djias[1].opening_price = 10001.01
    djias[1].high_price = 10002.02
    djias[1].low_price = 10003.03
    djias[1].close_price = 10004.04

    djias << DowJonesIndustrialAverage.new(date: Date.parse("2017-09-04"), opening_price: "3100.31".to_d, high_price: "3200.32".to_d, low_price: "3300.33".to_d, close_price: "3400.34".to_d)

    djia_ids = DowJonesIndustrialAverage.import(djias)

    assert_equal 4, djia_ids.length
    djia_ids.each do |djia_id|
      assert DowJonesIndustrialAverage.find(djia_id)
    end

    assert_equal 4, DowJonesIndustrialAverage.all.length
    djias.each do |djia|
      djia_actual = DowJonesIndustrialAverage.find_by(date: djia.date)

      assert_equal djia.opening_price, djia_actual.opening_price
      assert_equal djia.high_price, djia_actual.high_price
      assert_equal djia.low_price, djia_actual.low_price
      assert_equal djia.close_price, djia_actual.close_price
    end
  end

end
