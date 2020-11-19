require 'test_helper'

class BoardControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get board_edit_url
    assert_response :success
  end

end
