require 'test_helper'

module ActionController
  module Serialization
    class LookupProcTest < ActionController::TestCase
      module Api
        module V3
          class PostCustomSerializer < ActiveModel::Serializer
            attributes :title, :body

            belongs_to :author
          end

          class AuthorCustomSerializer < ActiveModel::Serializer
            attributes :name
          end

          class LookupProcTestController < ActionController::Base
            def implicit_namespaced_serializer
              author = Author.new(name: 'Bob')
              post = Post.new(title: 'New Post', body: 'Body', author: author)

              render json: post
            end
          end
        end
      end

      tests Api::V3::LookupProcTestController

      test 'implicitly uses namespaced serializer' do
        controller_namespace = lambda do |resource_class, _parent_serializer_class, namespace|
          "#{namespace}::#{resource_class}CustomSerializer" if namespace
        end

        with_prepended_lookup(controller_namespace) do
          get :implicit_namespaced_serializer

          assert_serializer Api::V3::PostCustomSerializer

          expected = { 'title' => 'New Post', 'body' => 'Body', 'author' => { 'name' => 'Bob' } }
          actual = JSON.parse(@response.body)

          assert_equal expected, actual
        end
      end
    end
  end
end
