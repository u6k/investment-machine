require 'test_helper'

class WertpapierReportTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download feed" do
    # precondition
    bucket = Stock._get_s3_bucket

    # execute 1
    result = WertpapierReport.download_feed("1301")

    # postcondition 1
    data = result[:data]
    wertpapier_reports = result[:wertpapier_reports]

    assert wertpapier_reports.length > 0

    assert_equal 0, WertpapierReport.all.length

    # execute 2
    object_keys = WertpapierReport.put_feed(bucket, "1301", data)

    # postcondition 2
    assert_equal "wertpapier_feed_1301.atom", object_keys[:original]
    assert_match /^wertpapier_feed_1301\.atom\.bak_[0-9]{8}-[0-9]{6}/, object_keys[:backup]
    assert bucket.object(object_keys[:original]).exists?
    assert bucket.object(object_keys[:backup]).exists?
  end

  test "get and import feed" do
    # precondition
    atom_file_path = Rails.root.join("test", "fixtures", "files", "wertpapier_report", "wertpapier_feed_1301.atom")
    data = File.open(atom_file_path).read

    # execute 1
    wertpapier_reports = WertpapierReport.get_feed("1301", data)

    # postcondition 1
    assert_equal 58, wertpapier_reports.length
    wertpapier_reports.each do |wertpapier_report|
      assert wertpapier_report.valid?
    end

    assert_equal 0, WertpapierReport.all.length

    # execute 2
    wertpapier_report_ids = WertpapierReport.import_feed(wertpapier_reports)

    # postcondition 2
    assert_equal 58, wertpapier_report_ids.length
    assert_equal 58, WertpapierReport.all.length

    wertpapier_reports.each do |wertpapier_report|
      wr = WertpapierReport.find_by(ticker_symbol: wertpapier_report.ticker_symbol, entry_id: wertpapier_report.entry_id)

      assert_equal wertpapier_report.title, wr.title
      assert_equal wertpapier_report.content_type, wr.content_type
      assert_equal wertpapier_report.entry_updated, wr.entry_updated
    end
  end

  test "download wertpapier zip" do
    # precondition
    bucket = Stock._get_s3_bucket

    wertpapier_reports = WertpapierReport.download_feed("1301")[:wertpapier_reports]
    WertpapierReport.import_feed(wertpapier_reports)

    entry_id = wertpapier_reports[0].entry_id

    # execute 1
    result = WertpapierReport.download_wertpapier_zip("1301", entry_id)

    # postcondition 1
    data = result[:data]

    assert data.length > 0

    # execute 2
    object_keys = WertpapierReport.put_wertpapier_zip(bucket, "1301", entry_id, data)

    # postcondition 2
    assert_equal "wertpapier_zip_1301_#{entry_id}.zip", object_keys[:original]
    assert_match /^wertpapier_zip_1301_#{entry_id}\.zip\.bak_[0-9]{8}-[0-9]{6}/, object_keys[:backup]
    assert bucket.object(object_keys[:original]).exists?
    assert bucket.object(object_keys[:backup]).exists?
    # TODO: assert valid zip
  end

end
