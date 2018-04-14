# frozen_string_literal: true

require 'test_helper'

class RoutesTest < Devise::ControllerTestCase
  tests ApplicationController

  def assert_path_and_url(name, prepend_path=nil)
    @request.path = '/users/session'
    prepend_path = "#{prepend_path}_" if prepend_path

    # Resource param
    assert_equal @controller.send(:"#{prepend_path}#{name}_path", :user),
                 send(:"#{prepend_path}user_#{name}_path")
    assert_equal @controller.send(:"#{prepend_path}#{name}_url", :user),
                 send(:"#{prepend_path}user_#{name}_url")

    # With string
    assert_equal @controller.send(:"#{prepend_path}#{name}_path", "user"),
                 send(:"#{prepend_path}user_#{name}_path")
    assert_equal @controller.send(:"#{prepend_path}#{name}_url", "user"),
                 send(:"#{prepend_path}user_#{name}_url")

    # Default url params
    assert_equal @controller.send(:"#{prepend_path}#{name}_path", :user, param: 123),
                 send(:"#{prepend_path}user_#{name}_path", param: 123)
    assert_equal @controller.send(:"#{prepend_path}#{name}_url", :user, param: 123),
                 send(:"#{prepend_path}user_#{name}_url", param: 123)

    @request.path = nil
    # With an object
    assert_equal @controller.send(:"#{prepend_path}#{name}_path", User.new),
                 send(:"#{prepend_path}user_#{name}_path")
    assert_equal @controller.send(:"#{prepend_path}#{name}_url", User.new),
                 send(:"#{prepend_path}user_#{name}_url")
  end


  test 'should alias session to mapped user session' do
    assert_path_and_url :session
    assert_path_and_url :session, :new
    assert_path_and_url :session, :destroy
  end

  test 'should alias password to mapped user password' do
    assert_path_and_url :password
    assert_path_and_url :password, :new
    assert_path_and_url :password, :edit
  end

  test 'should alias confirmation to mapped user confirmation' do
    assert_path_and_url :confirmation
    assert_path_and_url :confirmation, :new
  end

  test 'should alias unlock to mapped user unlock' do
    assert_path_and_url :unlock
    assert_path_and_url :unlock, :new
  end

  test 'should alias registration to mapped user registration' do
    assert_path_and_url :registration
    assert_path_and_url :registration, :new
    assert_path_and_url :registration, :edit
    assert_path_and_url :registration, :cancel
  end
end
