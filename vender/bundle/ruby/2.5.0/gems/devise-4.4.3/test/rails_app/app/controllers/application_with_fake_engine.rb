# frozen_string_literal: true

class ApplicationWithFakeEngine < ApplicationController
  private

  helper_method :fake_engine
  def fake_engine
    @fake_engine ||= FakeEngine.new
  end
end

class FakeEngine
  def user_on_engine_confirmation_path
    '/user_on_engine/confirmation'
  end

  def new_user_on_engine_session_path
    '/user_on_engine/confirmation/new'
  end

  def new_user_on_engine_registration_path
    '/user_on_engine/registration/new'
  end

  def new_user_on_engine_password_path
    '/user_on_engine/password/new'
  end

  def new_user_on_engine_unlock_path
    '/user_on_engine/unlock/new'
  end
end
