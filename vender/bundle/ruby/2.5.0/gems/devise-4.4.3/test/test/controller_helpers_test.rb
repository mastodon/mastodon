# frozen_string_literal: true

require 'test_helper'

class TestControllerHelpersTest < Devise::ControllerTestCase
  tests UsersController
  include Devise::Test::ControllerHelpers

  test "redirects if attempting to access a page unauthenticated" do
    get :index
    assert_redirected_to new_user_session_path
    assert_equal "You need to sign in or sign up before continuing.", flash[:alert]
  end

  test "redirects if attempting to access a page with an unconfirmed account" do
    swap Devise, allow_unconfirmed_access_for: 0.days do
      user = create_user
      assert !user.active_for_authentication?

      sign_in user
      get :index
      assert_redirected_to new_user_session_path
    end
  end

  test "returns nil if accessing current_user with an unconfirmed account" do
    swap Devise, allow_unconfirmed_access_for: 0.days do
      user = create_user
      assert !user.active_for_authentication?

      sign_in user
      get :accept, params: { id: user }
      assert_nil assigns(:current_user)
    end
  end

  test "does not redirect with valid user" do
    user = create_user
    user.confirm

    sign_in user
    get :index
    assert_response :success
  end

  test "does not redirect with valid user after failed first attempt" do
    get :index
    assert_response :redirect

    user = create_user
    user.confirm

    sign_in user
    get :index
    assert_response :success
  end

  test "redirects if valid user signed out" do
    user = create_user
    user.confirm

    sign_in user
    get :index

    sign_out user
    get :index
    assert_redirected_to new_user_session_path
  end

  test "respects custom failure app" do
    custom_failure_app = Class.new(Devise::FailureApp) do
      def redirect
        self.status = 300
      end
    end

    swap Devise.warden_config, failure_app: custom_failure_app do
      get :index
      assert_response 300
    end
  end

  test "passes given headers from the failure app to the response" do
    custom_failure_app = Class.new(Devise::FailureApp) do
      def respond
        self.status = 401
        self.response.headers["CUSTOMHEADER"] = 1
      end
    end

    swap Devise.warden_config, failure_app: custom_failure_app do
      sign_in create_user
      get :index
      assert_equal 1, @response.headers["CUSTOMHEADER"]
    end
  end

  test "returns the body of a failure app" do
    get :index
    assert_equal response.body, "<html><body>You are being <a href=\"http://test.host/users/sign_in\">redirected</a>.</body></html>"
  end

  test "returns the content type of a failure app" do
    get :index, params: { format: :xml }
    assert response.content_type.include?('application/xml')
  end

  test "defined Warden after_authentication callback should not be called when sign_in is called" do
    begin
      Warden::Manager.after_authentication do |user, auth, opts|
        flunk "callback was called while it should not"
      end

      user = create_user
      user.confirm
      sign_in user
    ensure
      Warden::Manager._after_set_user.pop
    end
  end

  test "defined Warden before_logout callback should not be called when sign_out is called" do
    begin
      Warden::Manager.before_logout do |user, auth, opts|
        flunk "callback was called while it should not"
      end
      user = create_user
      user.confirm

      sign_in user
      sign_out user
    ensure
      Warden::Manager._before_logout.pop
    end
  end

  test "before_failure call should work" do
    begin
      executed = false
      Warden::Manager.before_failure do |env,opts|
        executed = true
      end

      user = create_user
      sign_in user

      get :index
      assert executed
    ensure
      Warden::Manager._before_failure.pop
    end
  end

  test "allows to sign in with different users" do
    first_user = create_user
    first_user.confirm

    sign_in first_user
    get :index
    assert_match /User ##{first_user.id}/, @response.body
    sign_out first_user

    second_user = create_user
    second_user.confirm

    sign_in second_user
    get :index
    assert_match /User ##{second_user.id}/, @response.body
  end

  test "creates a new warden proxy if the request object has changed" do
    old_warden_proxy = warden

    @request = if Devise::Test.rails51? || Devise::Test.rails52?
      ActionController::TestRequest.create(Class.new) # needs a "controller class"
    elsif Devise::Test.rails5?
      ActionController::TestRequest.create
    else
      ActionController::TestRequest.new
    end

    new_warden_proxy = warden

    assert_not_equal old_warden_proxy, new_warden_proxy
  end

  test "doesn't create a new warden proxy if the request object hasn't changed" do
    old_warden_proxy = warden
    new_warden_proxy = warden

    assert_equal old_warden_proxy, new_warden_proxy
  end
end
