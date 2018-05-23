# frozen_string_literal: true

require 'test_helper'

class MyMountableEngine
  def self.call(env)
    ['200', { 'Content-Type' => 'text/html' }, ['Rendered content of MyMountableEngine']]
  end
end

# If disable_clear_and_finalize is set to true, Rails will not clear other routes when calling
# again the draw method. Look at the source code at:
# http://www.rubydoc.info/docs/rails/ActionDispatch/Routing/RouteSet:draw
Rails.application.routes.disable_clear_and_finalize = true

Rails.application.routes.draw do
  authenticate(:user) do
    mount MyMountableEngine, at: '/mountable_engine'
  end
end

class AuthenticatedMountedEngineTest < Devise::IntegrationTest
  test 'redirects to the sign in page when not authenticated' do
    get '/mountable_engine'
    follow_redirect!

    assert_response :ok
    assert_contain 'You need to sign in or sign up before continuing.'
  end

  test 'renders the mounted engine when authenticated' do
    sign_in_as_user
    get '/mountable_engine'

    assert_response :success
    assert_contain 'Rendered content of MyMountableEngine'
  end
end
