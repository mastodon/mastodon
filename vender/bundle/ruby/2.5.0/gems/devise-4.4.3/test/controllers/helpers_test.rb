# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class ControllerAuthenticatableTest < Devise::ControllerTestCase
  tests ApplicationController

  def setup
    @mock_warden = OpenStruct.new
    @controller.request.env['warden'] = @mock_warden
  end

  test 'provide access to warden instance' do
    assert_equal @mock_warden, @controller.warden
  end

  test 'proxy signed_in?(scope) to authenticate?' do
    @mock_warden.expects(:authenticate?).with(scope: :my_scope)
    @controller.signed_in?(:my_scope)
  end

  test 'proxy signed_in?(nil) to authenticate?' do
    Devise.mappings.keys.each do |scope| # :user, :admin, :manager
      @mock_warden.expects(:authenticate?).with(scope: scope)
    end
    @controller.signed_in?
  end

  test 'proxy [group]_signed_in? to authenticate? with each scope' do
    [:user, :admin].each do |scope|
      @mock_warden.expects(:authenticate?).with(scope: scope).returns(false)
    end
    @controller.commenter_signed_in?
  end

  test 'proxy current_user to authenticate with user scope' do
    @mock_warden.expects(:authenticate).with(scope: :user)
    @controller.current_user
  end

  test 'proxy current_admin to authenticate with admin scope' do
    @mock_warden.expects(:authenticate).with(scope: :admin)
    @controller.current_admin
  end

  test 'proxy current_[group] to authenticate with each scope' do
    [:user, :admin].each do |scope|
      @mock_warden.expects(:authenticate).with(scope: scope).returns(nil)
    end
    @controller.current_commenter
  end

  test 'proxy current_[plural_group] to authenticate with each scope' do
    [:user, :admin].each do |scope|
      @mock_warden.expects(:authenticate).with(scope: scope)
    end
    @controller.current_commenters
  end

  test 'proxy current_publisher_account to authenticate with namespaced publisher account scope' do
    @mock_warden.expects(:authenticate).with(scope: :publisher_account)
    @controller.current_publisher_account
  end

  test 'proxy authenticate_user! to authenticate with user scope' do
    @mock_warden.expects(:authenticate!).with(scope: :user)
    @controller.authenticate_user!
  end

  test 'proxy authenticate_user! options to authenticate with user scope' do
    @mock_warden.expects(:authenticate!).with(scope: :user, recall: "foo")
    @controller.authenticate_user!(recall: "foo")
  end

  test 'proxy authenticate_admin! to authenticate with admin scope' do
    @mock_warden.expects(:authenticate!).with(scope: :admin)
    @controller.authenticate_admin!
  end

  test 'proxy authenticate_[group]! to authenticate!? with each scope' do
    [:user, :admin].each do |scope|
      @mock_warden.expects(:authenticate!).with(scope: scope)
      @mock_warden.expects(:authenticate?).with(scope: scope).returns(false)
    end
    @controller.authenticate_commenter!
  end

  test 'proxy authenticate_publisher_account! to authenticate with namespaced publisher account scope' do
    @mock_warden.expects(:authenticate!).with(scope: :publisher_account)
    @controller.authenticate_publisher_account!
  end

  test 'proxy user_signed_in? to authenticate with user scope' do
    @mock_warden.expects(:authenticate).with(scope: :user).returns("user")
    assert @controller.user_signed_in?
  end

  test 'proxy admin_signed_in? to authenticatewith admin scope' do
    @mock_warden.expects(:authenticate).with(scope: :admin)
    refute @controller.admin_signed_in?
  end

  test 'proxy publisher_account_signed_in? to authenticate with namespaced publisher account scope' do
    @mock_warden.expects(:authenticate).with(scope: :publisher_account)
    @controller.publisher_account_signed_in?
  end

  test 'proxy user_session to session scope in warden' do
    @mock_warden.expects(:authenticate).with(scope: :user).returns(true)
    @mock_warden.expects(:session).with(:user).returns({})
    @controller.user_session
  end

  test 'proxy admin_session to session scope in warden' do
    @mock_warden.expects(:authenticate).with(scope: :admin).returns(true)
    @mock_warden.expects(:session).with(:admin).returns({})
    @controller.admin_session
  end

  test 'proxy publisher_account_session from namespaced scope to session scope in warden' do
    @mock_warden.expects(:authenticate).with(scope: :publisher_account).returns(true)
    @mock_warden.expects(:session).with(:publisher_account).returns({})
    @controller.publisher_account_session
  end

  test 'sign in proxy to set_user on warden' do
    user = User.new
    @mock_warden.expects(:user).returns(nil)
    @mock_warden.expects(:set_user).with(user, scope: :user).returns(true)
    @controller.sign_in(:user, user)
  end

  test 'sign in accepts a resource as argument' do
    user = User.new
    @mock_warden.expects(:user).returns(nil)
    @mock_warden.expects(:set_user).with(user, scope: :user).returns(true)
    @controller.sign_in(user)
  end

  test 'does not sign in again if the user is already in' do
    user = User.new
    @mock_warden.expects(:user).returns(user)
    @mock_warden.expects(:set_user).never
    assert @controller.sign_in(user)
  end

  test 'sign in again when the user is already in only if force is given' do
    user = User.new
    @mock_warden.expects(:user).returns(user)
    @mock_warden.expects(:set_user).with(user, scope: :user).returns(true)
    @controller.sign_in(user, force: true)
  end

  test 'bypass the sign in' do
    user = User.new
    @mock_warden.expects(:session_serializer).returns(serializer = mock())
    serializer.expects(:store).with(user, :user)
    @controller.bypass_sign_in(user)
  end

  test 'sign out clears up any signed in user from all scopes' do
    user = User.new
    @mock_warden.expects(:user).times(Devise.mappings.size)
    @mock_warden.expects(:logout).with().returns(true)
    @controller.instance_variable_set(:@current_user, user)
    @controller.instance_variable_set(:@current_admin, user)
    @controller.sign_out
    assert_nil @controller.instance_variable_get(:@current_user)
    assert_nil @controller.instance_variable_get(:@current_admin)
  end

  test 'sign out logs out and clears up any signed in user by scope' do
    user = User.new
    @mock_warden.expects(:user).with(scope: :user, run_callbacks: false).returns(user)
    @mock_warden.expects(:logout).with(:user).returns(true)
    @mock_warden.expects(:clear_strategies_cache!).with(scope: :user).returns(true)
    @controller.instance_variable_set(:@current_user, user)
    @controller.sign_out(:user)
    assert_nil @controller.instance_variable_get(:@current_user)
  end

  test 'sign out accepts a resource as argument' do
    @mock_warden.expects(:user).with(scope: :user, run_callbacks: false).returns(true)
    @mock_warden.expects(:logout).with(:user).returns(true)
    @mock_warden.expects(:clear_strategies_cache!).with(scope: :user).returns(true)
    @controller.sign_out(User.new)
  end

  test 'sign out without args proxy to sign out all scopes' do
    @mock_warden.expects(:user).times(Devise.mappings.size)
    @mock_warden.expects(:logout).with().returns(true)
    @mock_warden.expects(:clear_strategies_cache!).with().returns(true)
    @controller.sign_out
  end

  test 'sign out everybody proxy to logout on warden' do
    @mock_warden.expects(:user).times(Devise.mappings.size)
    @mock_warden.expects(:logout).with().returns(true)
    @controller.sign_out_all_scopes
  end

  test 'stored location for returns the location for a given scope' do
    assert_nil @controller.stored_location_for(:user)
    @controller.session[:"user_return_to"] = "/foo.bar"
    assert_equal "/foo.bar", @controller.stored_location_for(:user)
  end

  test 'stored location for accepts a resource as argument' do
    assert_nil @controller.stored_location_for(:user)
    @controller.session[:"user_return_to"] = "/foo.bar"
    assert_equal "/foo.bar", @controller.stored_location_for(User.new)
  end

  test 'stored location cleans information after reading' do
    @controller.session[:"user_return_to"] = "/foo.bar"
    assert_equal "/foo.bar", @controller.stored_location_for(:user)
    assert_nil @controller.session[:"user_return_to"]
  end

  test 'store location for stores a location to redirect back to' do
    assert_nil @controller.stored_location_for(:user)
    @controller.store_location_for(:user, "/foo.bar")
    assert_equal "/foo.bar", @controller.stored_location_for(:user)
  end

  test 'store bad location for stores a location to redirect back to' do
    assert_nil @controller.stored_location_for(:user)
    @controller.store_location_for(:user, "/foo.bar\">Carry")
    assert_nil @controller.stored_location_for(:user)
  end

  test 'store location for accepts a resource as argument' do
    @controller.store_location_for(User.new, "/foo.bar")
    assert_equal "/foo.bar", @controller.stored_location_for(User.new)
  end

  test 'store location for stores paths' do
    @controller.store_location_for(:user, "//host/foo.bar")
    assert_equal "/foo.bar", @controller.stored_location_for(:user)
    @controller.store_location_for(:user, "///foo.bar")
    assert_equal "/foo.bar", @controller.stored_location_for(:user)
  end

  test 'store location for stores query string' do
    @controller.store_location_for(:user, "/foo?bar=baz")
    assert_equal "/foo?bar=baz", @controller.stored_location_for(:user)
  end

  test 'store location for stores fragments' do
    @controller.store_location_for(:user, "/foo#bar")
    assert_equal "/foo#bar", @controller.stored_location_for(:user)
  end

  test 'after sign in path defaults to root path if none by was specified for the given scope' do
    assert_equal root_path, @controller.after_sign_in_path_for(:user)
  end

  test 'after sign in path defaults to the scoped root path' do
    assert_equal admin_root_path, @controller.after_sign_in_path_for(:admin)
  end

  test 'after sign out path defaults to the root path' do
    assert_equal root_path, @controller.after_sign_out_path_for(:admin)
    assert_equal root_path, @controller.after_sign_out_path_for(:user)
  end

  test 'sign in and redirect uses the stored location' do
    user = User.new
    @controller.session[:user_return_to] = "/foo.bar"
    @mock_warden.expects(:user).with(:user).returns(nil)
    @mock_warden.expects(:set_user).with(user, scope: :user).returns(true)
    @controller.expects(:redirect_to).with("/foo.bar")
    @controller.sign_in_and_redirect(user)
  end

  test 'sign in and redirect uses the configured after sign in path' do
    admin = Admin.new
    @mock_warden.expects(:user).with(:admin).returns(nil)
    @mock_warden.expects(:set_user).with(admin, scope: :admin).returns(true)
    @controller.expects(:redirect_to).with(admin_root_path)
    @controller.sign_in_and_redirect(admin)
  end

  test 'sign in and redirect does not sign in again if user is already signed' do
    admin = Admin.new
    @mock_warden.expects(:user).with(:admin).returns(admin)
    @mock_warden.expects(:set_user).never
    @controller.expects(:redirect_to).with(admin_root_path)
    @controller.sign_in_and_redirect(admin)
  end

  test 'sign out and redirect uses the configured after sign out path when signing out only the current scope' do
    swap Devise, sign_out_all_scopes: false do
      @mock_warden.expects(:user).with(scope: :admin, run_callbacks: false).returns(true)
      @mock_warden.expects(:logout).with(:admin).returns(true)
      @mock_warden.expects(:clear_strategies_cache!).with(scope: :admin).returns(true)
      @controller.expects(:redirect_to).with(admin_root_path)
      @controller.instance_eval "def after_sign_out_path_for(resource); admin_root_path; end"
      @controller.sign_out_and_redirect(:admin)
    end
  end

  test 'sign out and redirect uses the configured after sign out path when signing out all scopes' do
    swap Devise, sign_out_all_scopes: true do
      @mock_warden.expects(:user).times(Devise.mappings.size)
      @mock_warden.expects(:logout).with().returns(true)
      @mock_warden.expects(:clear_strategies_cache!).with().returns(true)
      @controller.expects(:redirect_to).with(admin_root_path)
      @controller.instance_eval "def after_sign_out_path_for(resource); admin_root_path; end"
      @controller.sign_out_and_redirect(:admin)
    end
  end

  test 'is not a devise controller' do
    refute @controller.devise_controller?
  end
end
