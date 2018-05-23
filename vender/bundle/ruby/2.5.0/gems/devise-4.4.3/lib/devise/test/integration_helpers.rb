# frozen_string_literal: true

module Devise
  # Devise::Test::IntegrationHelpers is a helper module for facilitating
  # authentication on Rails integration tests to bypass the required steps for
  # signin in or signin out a record.
  #
  # Examples
  #
  #  class PostsTest < ActionDispatch::IntegrationTest
  #    include Devise::Test::IntegrationHelpers
  #
  #    test 'authenticated users can see posts' do
  #      sign_in users(:bob)
  #
  #      get '/posts'
  #      assert_response :success
  #    end
  #  end
  module Test
    module IntegrationHelpers
      def self.included(base)
        base.class_eval do
          include Warden::Test::Helpers

          setup :setup_integration_for_devise
          teardown :teardown_integration_for_devise
        end
      end

      # Signs in a specific resource, mimicking a successfull sign in
      # operation through +Devise::SessionsController#create+.
      #
      # * +resource+ - The resource that should be authenticated
      # * +scope+    - An optional +Symbol+ with the scope where the resource
      #                should be signed in with.
      def sign_in(resource, scope: nil)
        scope ||= Devise::Mapping.find_scope!(resource)

        login_as(resource, scope: scope)
      end

      # Signs out a specific scope from the session.
      #
      # * +resource_or_scope+ - The resource or scope that should be signed out.
      def sign_out(resource_or_scope)
        scope = Devise::Mapping.find_scope!(resource_or_scope)

        logout scope
      end

      protected

      def setup_integration_for_devise
        Warden.test_mode!
      end

      def teardown_integration_for_devise
        Warden.test_reset!
      end
    end
  end
end
