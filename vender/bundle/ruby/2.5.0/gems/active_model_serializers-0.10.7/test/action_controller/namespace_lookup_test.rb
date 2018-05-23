require 'test_helper'

module ActionController
  module Serialization
    class NamespaceLookupTest < ActionController::TestCase
      class Book < ::Model
        attributes :id, :title, :body
        associations :writer, :chapters
      end
      class Chapter < ::Model
        attributes :title
      end
      class Writer < ::Model
        attributes :name
      end

      module Api
        module V2
          class BookSerializer < ActiveModel::Serializer
            attributes :title
          end
        end

        module VHeader
          class BookSerializer < ActiveModel::Serializer
            attributes :title, :body

            def body
              'header'
            end
          end
        end

        module V3
          class BookSerializer < ActiveModel::Serializer
            attributes :title, :body

            belongs_to :writer
            has_many :chapters
          end

          class ChapterSerializer < ActiveModel::Serializer
            attribute :title do
              "Chapter - #{object.title}"
            end
          end

          class WriterSerializer < ActiveModel::Serializer
            attributes :name
          end

          class LookupTestController < ActionController::Base
            before_action only: [:namespace_set_in_before_filter] do
              self.namespace_for_serializer = Api::V2
            end

            def implicit_namespaced_serializer
              writer = Writer.new(name: 'Bob')
              book = Book.new(title: 'New Post', body: 'Body', writer: writer, chapters: [])

              render json: book
            end

            def implicit_namespaced_collection_serializer
              chapter1 = Chapter.new(title: 'Oh')
              chapter2 = Chapter.new(title: 'Oh my')

              render json: [chapter1, chapter2]
            end

            def implicit_has_many_namespaced_serializer
              chapter1 = Chapter.new(title: 'Odd World')
              chapter2 = Chapter.new(title: 'New World')
              book = Book.new(title: 'New Post', body: 'Body', chapters: [chapter1, chapter2])

              render json: book
            end

            def explicit_namespace_as_module
              book = Book.new(title: 'New Post', body: 'Body')

              render json: book, namespace: Api::V2
            end

            def explicit_namespace_as_string
              book = Book.new(title: 'New Post', body: 'Body')

              # because this is a string, ruby can't auto-lookup the constant, so otherwise
              # the lookup thinks we mean ::Api::V2
              render json: book, namespace: 'ActionController::Serialization::NamespaceLookupTest::Api::V2'
            end

            def explicit_namespace_as_symbol
              book = Book.new(title: 'New Post', body: 'Body')

              # because this is a string, ruby can't auto-lookup the constant, so otherwise
              # the lookup thinks we mean ::Api::V2
              render json: book, namespace: :'ActionController::Serialization::NamespaceLookupTest::Api::V2'
            end

            def invalid_namespace
              book = Book.new(id: 'invalid_namespace_book_id', title: 'New Post', body: 'Body')

              render json: book, namespace: :api_v2
            end

            def namespace_set_in_before_filter
              book = Book.new(title: 'New Post', body: 'Body')
              render json: book
            end

            def namespace_set_by_request_headers
              book = Book.new(title: 'New Post', body: 'Body')
              version_from_header = request.headers['X-API_VERSION']
              namespace = "ActionController::Serialization::NamespaceLookupTest::#{version_from_header}"

              render json: book, namespace: namespace
            end
          end
        end
      end

      tests Api::V3::LookupTestController

      setup do
        @test_namespace = self.class.parent
      end

      test 'uses request headers to determine the namespace' do
        request.env['X-API_VERSION'] = 'Api::VHeader'
        get :namespace_set_by_request_headers

        assert_serializer Api::VHeader::BookSerializer
      end

      test 'implicitly uses namespaced serializer' do
        get :implicit_namespaced_serializer

        assert_serializer Api::V3::BookSerializer

        expected = { 'title' => 'New Post', 'body' => 'Body', 'writer' => { 'name' => 'Bob' }, 'chapters' => [] }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'implicitly uses namespaced serializer for collection' do
        get :implicit_namespaced_collection_serializer

        assert_serializer 'ActiveModel::Serializer::CollectionSerializer'

        expected = [{ 'title' => 'Chapter - Oh' }, { 'title' => 'Chapter - Oh my' }]
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'implicitly uses namespaced serializer for has_many' do
        get :implicit_has_many_namespaced_serializer

        assert_serializer Api::V3::BookSerializer

        expected = {
          'title' => 'New Post',
          'body' => 'Body', 'writer' => nil,
          'chapters' => [
            { 'title' => 'Chapter - Odd World' },
            { 'title' => 'Chapter - New World' }
          ]
        }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'explicit namespace as module' do
        get :explicit_namespace_as_module

        assert_serializer Api::V2::BookSerializer

        expected = { 'title' => 'New Post' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'explicit namespace as string' do
        get :explicit_namespace_as_string

        assert_serializer Api::V2::BookSerializer

        expected = { 'title' => 'New Post' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'explicit namespace as symbol' do
        get :explicit_namespace_as_symbol

        assert_serializer Api::V2::BookSerializer

        expected = { 'title' => 'New Post' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'invalid namespace' do
        get :invalid_namespace

        assert_serializer ActiveModel::Serializer::Null

        expected = { 'id' => 'invalid_namespace_book_id', 'title' => 'New Post', 'body' => 'Body' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'namespace set in before filter' do
        get :namespace_set_in_before_filter

        assert_serializer Api::V2::BookSerializer

        expected = { 'title' => 'New Post' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end
    end
  end
end
