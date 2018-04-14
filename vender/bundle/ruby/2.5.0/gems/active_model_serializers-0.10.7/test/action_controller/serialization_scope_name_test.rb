require 'test_helper'

module SerializationScopeTesting
  class User < ActiveModelSerializers::Model
    attributes :id, :name, :admin
    def admin?
      admin
    end
  end
  class Comment < ActiveModelSerializers::Model
    attributes :id, :body
  end
  class Post < ActiveModelSerializers::Model
    attributes :id, :title, :body, :comments
  end
  class PostSerializer < ActiveModel::Serializer
    attributes :id, :title, :body, :comments

    def body
      "The 'scope' is the 'current_user': #{scope == current_user}"
    end

    def comments
      if current_user.admin?
        [Comment.new(id: 1, body: 'Admin')]
      else
        [Comment.new(id: 2, body: 'Scoped')]
      end
    end

    def json_key
      'post'
    end
  end
  class PostTestController < ActionController::Base
    attr_writer :current_user

    def render_post_by_non_admin
      self.current_user = User.new(id: 3, name: 'Pete', admin: false)
      render json: new_post, serializer: serializer, adapter: :json
    end

    def render_post_by_admin
      self.current_user = User.new(id: 3, name: 'Pete', admin: true)
      render json: new_post, serializer: serializer, adapter: :json
    end

    def current_user
      defined?(@current_user) ? @current_user : :current_user_not_set
    end

    private

    def new_post
      Post.new(id: 4, title: 'Title')
    end

    def serializer
      PostSerializer
    end
  end
  class PostViewContextSerializer < PostSerializer
    def body
      "The 'scope' is the 'view_context': #{scope == view_context}"
    end

    def comments
      if view_context.controller.current_user.admin?
        [Comment.new(id: 1, body: 'Admin')]
      else
        [Comment.new(id: 2, body: 'Scoped')]
      end
    end
  end
  class DefaultScopeTest < ActionController::TestCase
    tests PostTestController

    def test_default_serialization_scope
      assert_equal :current_user, @controller._serialization_scope
    end

    def test_default_serialization_scope_object
      assert_equal :current_user_not_set, @controller.current_user
      assert_equal :current_user_not_set, @controller.serialization_scope
    end

    def test_default_scope_non_admin
      get :render_post_by_non_admin
      expected_json = {
        post: {
          id: 4,
          title: 'Title',
          body: "The 'scope' is the 'current_user': true",
          comments: [
            { id: 2, body: 'Scoped' }
          ]
        }
      }.to_json
      assert_equal expected_json, @response.body
    end

    def test_default_scope_admin
      get :render_post_by_admin
      expected_json = {
        post: {
          id: 4,
          title: 'Title',
          body: "The 'scope' is the 'current_user': true",
          comments: [
            { id: 1, body: 'Admin' }
          ]
        }
      }.to_json
      assert_equal expected_json, @response.body
    end
  end
  class SerializationScopeTest < ActionController::TestCase
    class PostViewContextTestController < PostTestController
      serialization_scope :view_context

      private

      def serializer
        PostViewContextSerializer
      end
    end
    tests PostViewContextTestController

    def test_defined_serialization_scope
      assert_equal :view_context, @controller._serialization_scope
    end

    def test_defined_serialization_scope_object
      assert_equal @controller.view_context.controller, @controller.serialization_scope.controller
    end

    def test_serialization_scope_non_admin
      get :render_post_by_non_admin
      expected_json = {
        post: {
          id: 4,
          title: 'Title',
          body: "The 'scope' is the 'view_context': true",
          comments: [
            { id: 2, body: 'Scoped' }
          ]
        }
      }.to_json
      assert_equal expected_json, @response.body
    end

    def test_serialization_scope_admin
      get :render_post_by_admin
      expected_json = {
        post: {
          id: 4,
          title: 'Title',
          body: "The 'scope' is the 'view_context': true",
          comments: [
            { id: 1, body: 'Admin' }
          ]
        }
      }.to_json
      assert_equal expected_json, @response.body
    end
  end
  class NilSerializationScopeTest < ActionController::TestCase
    class PostViewContextTestController < ActionController::Base
      serialization_scope nil

      attr_accessor :current_user

      def render_post_with_no_scope
        self.current_user = User.new(id: 3, name: 'Pete', admin: false)
        render json: new_post, serializer: PostSerializer, adapter: :json
      end

      def render_post_with_passed_in_scope
        self.current_user = User.new(id: 3, name: 'Pete', admin: false)
        render json: new_post, serializer: PostSerializer, adapter: :json, scope: current_user, scope_name: :current_user
      end

      def render_post_with_passed_in_scope_without_scope_name
        self.current_user = User.new(id: 3, name: 'Pete', admin: false)
        render json: new_post, serializer: PostSerializer, adapter: :json, scope: current_user
      end

      private

      def new_post
        Post.new(id: 4, title: 'Title')
      end
    end
    tests PostViewContextTestController

    def test_nil_serialization_scope
      assert_nil @controller._serialization_scope
    end

    def test_nil_serialization_scope_object
      assert_nil @controller.serialization_scope
    end

    def test_nil_scope
      exception_matcher = /current_user/
      exception = assert_raises(NameError) do
        get :render_post_with_no_scope
      end
      assert_match exception_matcher, exception.message
    end

    def test_serialization_scope_is_and_nil_scope_passed_in_current_user
      get :render_post_with_passed_in_scope
      expected_json = {
        post: {
          id: 4,
          title: 'Title',
          body: "The 'scope' is the 'current_user': true",
          comments: [
            { id: 2, body: 'Scoped' }
          ]
        }
      }.to_json
      assert_equal expected_json, @response.body
    end

    def test_serialization_scope_is_nil_and_scope_passed_in_current_user_without_scope_name
      exception_matcher = /current_user/
      exception = assert_raises(NameError) do
        get :render_post_with_passed_in_scope_without_scope_name
      end
      assert_match exception_matcher, exception.message
    end
  end
end
