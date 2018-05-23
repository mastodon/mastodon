require 'test_helper'

module ActiveModel
  class Serializer
    class SerializerForWithNamespaceTest < ActiveSupport::TestCase
      class Book < ::Model
        attributes :title, :author_name
        associations :publisher, :pages
      end
      class Page < ::Model; attributes :number, :text end
      class Publisher < ::Model; attributes :name end

      module Api
        module V3
          class BookSerializer < ActiveModel::Serializer
            attributes :title, :author_name

            has_many :pages
            belongs_to :publisher
          end

          class PageSerializer < ActiveModel::Serializer
            attributes :number, :text
          end

          class PublisherSerializer < ActiveModel::Serializer
            attributes :name
          end
        end
      end

      class BookSerializer < ActiveModel::Serializer
        attributes :title, :author_name
      end
      test 'resource without a namespace' do
        book = Book.new(title: 'A Post', author_name: 'hello')

        # TODO: this should be able to pull up this serializer without explicitly specifying the serializer
        #       currently, with no options, it still uses the Api::V3 serializer
        result = ActiveModelSerializers::SerializableResource.new(book, serializer: BookSerializer).serializable_hash

        expected = { title: 'A Post', author_name: 'hello' }
        assert_equal expected, result
      end

      test 'resource with namespace' do
        book = Book.new(title: 'A Post', author_name: 'hi')

        result = ActiveModelSerializers::SerializableResource.new(book, namespace: Api::V3).serializable_hash

        expected = { title: 'A Post', author_name: 'hi', pages: nil, publisher: nil }
        assert_equal expected, result
      end

      test 'has_many with nested serializer under the namespace' do
        page = Page.new(number: 1, text: 'hello')
        book = Book.new(title: 'A Post', author_name: 'hi', pages: [page])

        result = ActiveModelSerializers::SerializableResource.new(book, namespace: Api::V3).serializable_hash

        expected = {
          title: 'A Post', author_name: 'hi',
          publisher: nil,
          pages: [{
            number: 1, text: 'hello'
          }]
        }
        assert_equal expected, result
      end

      test 'belongs_to with nested serializer under the namespace' do
        publisher = Publisher.new(name: 'Disney')
        book = Book.new(title: 'A Post', author_name: 'hi', publisher: publisher)

        result = ActiveModelSerializers::SerializableResource.new(book, namespace: Api::V3).serializable_hash

        expected = {
          title: 'A Post', author_name: 'hi',
          pages: nil,
          publisher: {
            name: 'Disney'
          }
        }
        assert_equal expected, result
      end
    end
  end
end
