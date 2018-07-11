require 'test_helper'

class EdinetCodeTest < ActiveSupport::TestCase

  def setup
    bucket = Stock._get_s3_bucket
    bucket.objects.batch_delete!
  end

  test "download edinet code list zip" do
    # precondition
    bucket = Stock._get_s3_bucket

    assert_equal 0, EdinetCode.all.length

    # execute
    result = EdinetCode.download_edinet_code_list

    # postcondition
    assert result[:data].length > 0
    assert result[:edinet_codes].length > 9000

    assert_equal 0, EdinetCode.all.length
  end

end
