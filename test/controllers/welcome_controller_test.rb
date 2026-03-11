require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index

    assert_response :success
  end

  test "should get featured review partial" do
    get :featured_review

    assert_response :success
  end
end
