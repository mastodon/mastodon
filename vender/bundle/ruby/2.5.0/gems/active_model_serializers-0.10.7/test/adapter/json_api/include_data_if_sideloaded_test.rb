require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class IncludeParamTest < ActiveSupport::TestCase
          IncludeParamAuthor = Class.new(::Model) do
            associations :tags, :posts, :roles
          end

          class CustomCommentLoader
            def all
              [{ foo: 'bar' }]
            end
          end
          class Tag < ::Model
            attributes :id, :name
          end

          class TagSerializer < ActiveModel::Serializer
            type 'tags'
            attributes :id, :name
          end

          class PostWithTagsSerializer < ActiveModel::Serializer
            type 'posts'
            attributes :id
            has_many :tags
          end

          class IncludeParamAuthorSerializer < ActiveModel::Serializer
            class_attribute :comment_loader

            has_many :tags, serializer: TagSerializer do
              link :self, '//example.com/link_author/relationships/tags'
              include_data :if_sideloaded
            end

            has_many :unlinked_tags, serializer: TagSerializer do
              include_data :if_sideloaded
            end

            has_many :posts, serializer: PostWithTagsSerializer do
              include_data :if_sideloaded
            end
            has_many :locations do
              include_data :if_sideloaded
            end
            has_many :comments do
              include_data :if_sideloaded
              IncludeParamAuthorSerializer.comment_loader.all
            end
            has_many :roles, key: :granted_roles do
              include_data :if_sideloaded
            end
          end

          def setup
            IncludeParamAuthorSerializer.comment_loader = Class.new(CustomCommentLoader).new
            @tag = Tag.new(id: 1337, name: 'mytag')
            @role = Role.new(id: 1337, name: 'myrole')
            @author = IncludeParamAuthor.new(
              id: 1337,
              tags: [@tag],
              roles: [@role]
            )
          end

          def test_relationship_not_loaded_when_not_included
            expected = {
              links: {
                self: '//example.com/link_author/relationships/tags'
              }
            }

            @author.define_singleton_method(:read_attribute_for_serialization) do |attr|
              fail 'should not be called' if attr == :tags
              super(attr)
            end

            assert_relationship(:tags, expected)
          end

          def test_relationship_included
            expected = {
              data: [
                {
                  id: '1337',
                  type: 'tags'
                }
              ],
              links: {
                self: '//example.com/link_author/relationships/tags'
              }
            }

            assert_relationship(:tags, expected, include: :tags)
          end

          def test_sideloads_included
            expected = [
              {
                id: '1337',
                type: 'tags',
                attributes: { name: 'mytag' }
              }
            ]
            hash = result(include: :tags)
            assert_equal(expected, hash[:included])
          end

          def test_sideloads_included_when_using_key
            expected = [
              {
                id: '1337',
                type: 'roles',
                attributes: {
                  name: 'myrole',
                  description: nil,
                  slug: 'myrole-1337'
                },
                relationships: {
                  author: { data: nil }
                }
              }
            ]

            hash = result(include: :granted_roles)
            assert_equal(expected, hash[:included])
          end

          def test_sideloads_not_included_when_using_name_when_key_defined
            hash = result(include: :roles)
            assert_nil(hash[:included])
          end

          def test_nested_relationship
            expected = {
              data: [
                {
                  id: '1337',
                  type: 'tags'
                }
              ],
              links: {
                self: '//example.com/link_author/relationships/tags'
              }
            }

            expected_no_data = {
              links: {
                self: '//example.com/link_author/relationships/tags'
              }
            }

            assert_relationship(:tags, expected, include: [:tags, { posts: :tags }])

            @author.define_singleton_method(:read_attribute_for_serialization) do |attr|
              fail 'should not be called' if attr == :tags
              super(attr)
            end

            assert_relationship(:tags, expected_no_data, include: { posts: :tags })
          end

          def test_include_params_with_no_block
            @author.define_singleton_method(:read_attribute_for_serialization) do |attr|
              fail 'should not be called' if attr == :locations
              super(attr)
            end

            expected = { meta: {} }

            assert_relationship(:locations, expected)
          end

          def test_block_relationship
            expected = {
              data: [
                { 'foo' => 'bar' }
              ]
            }

            assert_relationship(:comments, expected, include: [:comments])
          end

          def test_node_not_included_when_no_link
            expected = { meta: {} }
            assert_relationship(:unlinked_tags, expected, key_transform: :unaltered)
          end

          private

          def assert_relationship(relationship_name, expected, opts = {})
            actual = relationship_data(relationship_name, opts)
            assert_equal(expected, actual)
          end

          def result(opts)
            opts = { adapter: :json_api }.merge(opts)
            serializable(@author, opts).serializable_hash
          end

          def relationship_data(relationship_name, opts = {})
            hash = result(opts)
            hash[:data][:relationships][relationship_name]
          end
        end
      end
    end
  end
end
