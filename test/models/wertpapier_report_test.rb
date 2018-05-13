require 'test_helper'

class WertpapierReportTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download feed and xbrl" do
    bucket = Stock._get_s3_bucket

    keys = WertpapierReport.download_feed("1301")

    assert_equal "wertpapier_feed_1301.atom", keys[:original]
    assert_match /^wertpapier_feed_1301\.atom\.bak_[0-9]{14}/, keys[:backup]
    assert bucket.object(keys[:original]).exists?
    assert bucket.object(keys[:backup]).exists?

    assert_equal 0, WertpapierReport.all.length
  end

end
