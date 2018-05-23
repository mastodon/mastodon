require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class RelationshipTest < ActiveSupport::TestCase
        def test_relationship_with_data
          expected = {
            data: {
              id: '1',
              type: 'blogs'
            }
          }

          model_attributes = { blog: Blog.new(id: 1) }
          relationship_name = :blog
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :blog
          end
          assert_equal(expected, actual)
        end

        def test_relationship_with_nil_model
          expected = { data: nil }

          model_attributes = { blog: nil }
          relationship_name = :blog
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :blog
          end
          assert_equal(expected, actual)
        end

        def test_relationship_with_data_array
          expected = {
            data: [
              {
                id: '1',
                type: 'posts'
              },
              {
                id: '2',
                type: 'posts'
              }
            ]
          }

          model_attributes = { posts: [Post.new(id: 1), Post.new(id: 2)] }
          relationship_name = :posts
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :posts
          end
          assert_equal(expected, actual)
        end

        def test_relationship_data_not_included
          expected = { meta: {} }

          model_attributes = { blog: :does_not_matter }
          relationship_name = :blog
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :blog do
              include_data false
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_many_links
          expected = {
            links: {
              self: 'a link',
              related: 'another link'
            }
          }

          model_attributes = { blog: :does_not_matter }
          relationship_name = :blog
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :blog do
              include_data false
              link :self, 'a link'
              link :related, 'another link'
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_block_link_with_meta
          expected = {
            links: {
              self: {
                href: '1',
                meta: { id: 1 }
              }
            }
          }

          model_attributes = { blog: Blog.new(id: 1) }
          relationship_name = :blog
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :blog do
              include_data false
              link :self do
                href object.blog.id.to_s
                meta(id: object.blog.id)
              end
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_simple_meta
          expected = { meta: { id: '1' } }

          model_attributes = { blog: Blog.new(id: 1) }
          relationship_name = :blog
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :blog do
              include_data false
              meta(id: object.blog.id.to_s)
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_block_meta
          expected = {
            meta: {
              id: 1
            }
          }

          model_attributes = { blog: Blog.new(id: 1) }
          relationship_name = :blog
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :blog do
              include_data false
              meta(id: object.blog.id)
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_simple_link
          expected = {
            data: {
              id: '1337',
              type: 'bios'
            },
            links: {
              self: '//example.com/link_author/relationships/bio'
            }
          }

          model_attributes = { bio: Bio.new(id: 1337) }
          relationship_name = :bio
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :bio do
              link :self, '//example.com/link_author/relationships/bio'
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_block_link
          expected = {
            data: { id: '1337', type: 'profiles' },
            links: { related: '//example.com/profiles/1337' }
          }

          model_attributes = { profile: Profile.new(id: 1337) }
          relationship_name = :profile
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :profile do
              id = object.profile.id
              link :related do
                "//example.com/profiles/#{id}" if id != 123
              end
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_with_everything
          expected = {
            data: [{ id: '1337', type: 'likes' }],
            links: {
              related: {
                href: '//example.com/likes/1337',
                meta: { ids: '1337' }
              }
            },
            meta: { liked: true }
          }

          model_attributes = { likes: [Like.new(id: 1337)] }
          relationship_name = :likes
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :likes do
              link :related do
                ids = object.likes.map(&:id).join(',')
                href "//example.com/likes/#{ids}"
                meta ids: ids
              end
              meta liked: object.likes.any?
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_nil_link
          expected = {
            data: { id: '123', type: 'profiles' }
          }

          model_attributes = { profile: Profile.new(id: 123) }
          relationship_name = :profile
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :profile do
              id = object.profile.id
              link :related do
                "//example.com/profiles/#{id}" if id != 123
              end
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_block_link_href
          expected = {
            data: [{ id: '1337', type: 'locations' }],
            links: {
              related: { href: '//example.com/locations/1337' }
            }
          }

          model_attributes = { locations: [Location.new(id: 1337)] }
          relationship_name = :locations
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :locations do
              link :related do
                ids = object.locations.map(&:id).join(',')
                href "//example.com/locations/#{ids}"
              end
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_block_link_href_and_meta
          expected = {
            data: [{ id: '1337', type: 'posts' }],
            links: {
              related: {
                href: '//example.com/posts/1337',
                meta: { ids: '1337' }
              }
            }
          }

          model_attributes =  { posts: [Post.new(id: 1337, comments: [], author: nil)] }
          relationship_name = :posts
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :posts do
              link :related do
                ids = object.posts.map(&:id).join(',')
                href "//example.com/posts/#{ids}"
                meta ids: ids
              end
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_block_link_meta
          expected = {
            data: [{ id: '1337', type: 'comments' }],
            links: {
              self: {
                meta: { ids: [1] }
              }
            }
          }

          model_attributes = { comments: [Comment.new(id: 1337)] }
          relationship_name = :comments
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :comments do
              link :self do
                meta ids: [1]
              end
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_meta
          expected = {
            data: [{ id: 'from-serializer-method', type: 'roles' }],
            meta: { count: 1 }
          }

          model_attributes = { roles: [Role.new(id: 'from-record')] }
          relationship_name = :roles
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :roles do |serializer|
              meta count: object.roles.count
              serializer.cached_roles
            end
            def cached_roles
              [
                Role.new(id: 'from-serializer-method')
              ]
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_not_including_data
          expected = {
            links: { self: '//example.com/link_author/relationships/blog' }
          }

          model_attributes = { blog: Object }
          relationship_name = :blog
          model = new_model(model_attributes)
          model.define_singleton_method(:read_attribute_for_serialization) do |attr|
            fail 'should not be called' if attr == :blog
            super(attr)
          end
          assert_nothing_raised do
            actual = build_serializer_and_serialize_relationship(model, relationship_name) do
              has_one :blog do
                link :self, '//example.com/link_author/relationships/blog'
                include_data false
              end
            end
            assert_equal(expected, actual)
          end
        end

        def test_relationship_including_data_explicit
          expected = {
            data: { id: '1337', type: 'authors' },
            meta: { name: 'Dan Brown' }
          }

          model_attributes = { reviewer: Author.new(id: 1337) }
          relationship_name = :reviewer
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            belongs_to :reviewer do
              meta name: 'Dan Brown'
              include_data true
            end
          end
          assert_equal(expected, actual)
        end

        private

        def build_serializer_and_serialize_relationship(model, relationship_name, &block)
          serializer_class = Class.new(ActiveModel::Serializer, &block)
          hash = serializable(model, serializer: serializer_class, adapter: :json_api).serializable_hash
          hash[:data][:relationships][relationship_name]
        end

        def new_model(model_attributes)
          Class.new(ActiveModelSerializers::Model) do
            attributes(*model_attributes.keys)

            def self.name
              'TestModel'
            end
          end.new(model_attributes)
        end
      end
    end
  end
end
