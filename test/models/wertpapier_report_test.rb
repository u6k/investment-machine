require 'test_helper'

class WertpapierReportTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download feed" do
    bucket = Stock._get_s3_bucket

    keys = WertpapierReport.download_feed("1301")

    assert_equal "wertpapier_feed_1301.atom", keys[:original]
    assert_match /^wertpapier_feed_1301\.atom\.bak_[0-9]{14}/, keys[:backup]
    assert bucket.object(keys[:original]).exists?
    assert bucket.object(keys[:backup]).exists?
    assert_equal 2, Stock._get_s3_objects_size(bucket.objects)

    assert_equal 0, WertpapierReport.all.length

    wertpapier_reports = WertpapierReport.get_feed("1301", keys[:original])

    assert wertpapier_reports.length > 0
    assert_equal 0, WertpapierReport.all.length
  end

  test "get and import feed" do
    bucket = Stock._get_s3_bucket
    atom_file_path = Rails.root.join("test", "fixtures", "files", "wertpapier_report", "wertpapier_feed_1301.atom")
    object = bucket.object("wertpapier_feed_1301.atom")
    object.upload_file(atom_file_path)

    wertpapier_reports = WertpapierReport.get_feed("1301", "wertpapier_feed_1301.atom")

    assert_equal 58, wertpapier_reports.length
    # TODO: assert model instances
    assert_equal 0, WertpapierReport.all.length

    wertpapier_report_ids = WertpapierReport.import_feed(wertpapier_reports)

    assert_equal 58, wertpapier_reports.length
    assert_equal 58, WertpapierReport.all.length
    # TODO: assert db data
  end

end
