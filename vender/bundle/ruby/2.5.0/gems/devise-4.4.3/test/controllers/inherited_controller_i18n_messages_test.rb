# frozen_string_literal: true

require 'test_helper'

class SessionsInheritedController < Devise::SessionsController
  def test_i18n_scope
    set_flash_message(:notice, :signed_in)
  end
end

class AnotherInheritedController < SessionsInheritedController
  protected

  def translation_scope
    'another'
  end
end

class InheritedControllerTest < Devise::ControllerTestCase
  tests SessionsInheritedController

  def setup
    @mock_warden = OpenStruct.new
    @controller.request.env['warden'] = @mock_warden
    @controller.request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test 'I18n scope is inherited from Devise::Sessions' do
    I18n.expects(:t).with do |message, options|
      message == 'user.signed_in' &&
        options[:scope] == 'devise.sessions'
    end
    @controller.test_i18n_scope
  end
end

class AnotherInheritedControllerTest < Devise::ControllerTestCase
  tests AnotherInheritedController

  def setup
    @mock_warden = OpenStruct.new
    @controller.request.env['warden'] = @mock_warden
    @controller.request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test 'I18n scope is overridden' do
    I18n.expects(:t).with do |message, options|
      message == 'user.signed_in' &&
        options[:scope] == 'another'
    end
    @controller.test_i18n_scope
  end
end
