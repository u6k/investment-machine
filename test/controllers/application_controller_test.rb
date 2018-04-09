require 'test_helper'

class HelloControllerTest < ActionDispatch::IntegrationTest

  test "display hello" do
    get root_url
    assert_response :success
  end

end
