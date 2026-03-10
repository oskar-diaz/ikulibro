require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should get index with featured review" do
    get :index

    assert_response :success
    assert_not_nil assigns(:featured_review)
  end
end
