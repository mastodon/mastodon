require 'test_helper'

module ActiveModel
  class Serializer
    class MetaTest < ActiveSupport::TestCase
      def setup
        @blog = Blog.new(id: 1,
                         name: 'AMS Hints',
                         writer: Author.new(id: 2, name: 'Steve'),
                         articles: [Post.new(id: 3, title: 'AMS')])
      end

      def test_meta_is_present_with_root
        actual = ActiveModelSerializers::SerializableResource.new(
          @blog,
          adapter: :json,
          serializer: AlternateBlogSerializer,
          meta: { total: 10 }
        ).as_json
        expected = {
          blog: {
            id: 1,
            title: 'AMS Hints'
          },
          'meta' => {
            total: 10
          }
        }
        assert_equal(expected, actual)
      end

      def test_meta_is_not_included_when_blank
        actual = ActiveModelSerializers::SerializableResource.new(
          @blog,
          adapter: :json,
          serializer: AlternateBlogSerializer,
          meta: {}
        ).as_json
        expected = {
          blog: {
            id: 1,
            title: 'AMS Hints'
          }
        }
        assert_equal(expected, actual)
      end

      def test_meta_is_not_included_when_empty_string
        actual = ActiveModelSerializers::SerializableResource.new(
          @blog,
          adapter: :json,
          serializer: AlternateBlogSerializer,
          meta: ''
        ).as_json
        expected = {
          blog: {
            id: 1,
            title: 'AMS Hints'
          }
        }
        assert_equal(expected, actual)
      end

      def test_meta_is_not_included_when_root_is_missing
        actual = ActiveModelSerializers::SerializableResource.new(
          @blog,
          adapter: :attributes,
          serializer: AlternateBlogSerializer,
          meta: { total: 10 }
        ).as_json
        expected = {
          id: 1,
          title: 'AMS Hints'
        }
        assert_equal(expected, actual)
      end

      def test_meta_key_is_used
        actual = ActiveModelSerializers::SerializableResource.new(
          @blog,
          adapter: :json,
          serializer: AlternateBlogSerializer,
          meta: { total: 10 },
          meta_key: 'haha_meta'
        ).as_json
        expected = {
          blog: {
            id: 1,
            title: 'AMS Hints'
          },
          'haha_meta' => {
            total: 10
          }
        }
        assert_equal(expected, actual)
      end

      def test_meta_key_is_not_used_with_json_api
        actual = ActiveModelSerializers::SerializableResource.new(
          @blog,
          adapter: :json_api,
          serializer: AlternateBlogSerializer,
          meta: { total: 10 },
          meta_key: 'haha_meta'
        ).as_json
        expected = {
          data: {
            id: '1',
            type: 'blogs',
            attributes: { title: 'AMS Hints' }
          },
          meta: { total: 10 }
        }
        assert_equal(expected, actual)
      end

      def test_meta_key_is_not_present_when_empty_hash_with_json_api
        actual = ActiveModelSerializers::SerializableResource.new(
          @blog,
          adapter: :json_api,
          serializer: AlternateBlogSerializer,
          meta: {}
        ).as_json
        expected = {
          data: {
            id: '1',
            type: 'blogs',
            attributes: { title: 'AMS Hints' }
          }
        }
        assert_equal(expected, actual)
      end

      def test_meta_key_is_not_present_when_empty_string_with_json_api
        actual = ActiveModelSerializers::SerializableResource.new(
          @blog,
          adapter: :json_api,
          serializer: AlternateBlogSerializer,
          meta: ''
        ).as_json
        expected = {
          data: {
            id: '1',
            type: 'blogs',
            attributes: { title: 'AMS Hints' }
          }
        }
        assert_equal(expected, actual)
      end

      def test_meta_is_not_present_on_arrays_without_root
        actual = ActiveModelSerializers::SerializableResource.new(
          [@blog],
          adapter: :attributes,
          meta: { total: 10 }
        ).as_json
        expected = [{
          id: 1,
          name: 'AMS Hints',
          writer: {
            id: 2,
            name: 'Steve'
          },
          articles: [{
            id: 3,
            title: 'AMS',
            body: nil
          }]
        }]
        assert_equal(expected, actual)
      end

      def test_meta_is_present_on_arrays_with_root
        actual = ActiveModelSerializers::SerializableResource.new(
          [@blog],
          adapter: :json,
          meta: { total: 10 },
          meta_key: 'haha_meta'
        ).as_json
        expected = {
          blogs: [{
            id: 1,
            name: 'AMS Hints',
            writer: {
              id: 2,
              name: 'Steve'
            },
            articles: [{
              id: 3,
              title: 'AMS',
              body: nil
            }]
          }],
          'haha_meta' => {
            total: 10
          }
        }
        assert_equal(expected, actual)
      end
    end
  end
end
