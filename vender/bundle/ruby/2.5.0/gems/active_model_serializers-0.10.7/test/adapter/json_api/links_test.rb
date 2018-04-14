require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class LinksTest < ActiveSupport::TestCase
        class LinkAuthor < ::Model; associations :posts end
        class LinkAuthorSerializer < ActiveModel::Serializer
          link :self do
            href "http://example.com/link_author/#{object.id}"
            meta stuff: 'value'
          end
          link(:author) { link_author_url(object.id) }
          link(:link_authors) { url_for(controller: 'link_authors', action: 'index', only_path: false) }
          link(:posts) { link_author_posts_url(object.id) }
          link :resource, 'http://example.com/resource'
          link :yet_another do
            "http://example.com/resource/#{object.id}"
          end
          link(:nil) { nil }
        end

        def setup
          Rails.application.routes.draw do
            resources :link_authors do
              resources :posts
            end
          end
          @post = Post.new(id: 1337, comments: [], author: nil)
          @author = LinkAuthor.new(id: 1337, posts: [@post])
        end

        def test_toplevel_links
          hash = ActiveModelSerializers::SerializableResource.new(
            @post,
            adapter: :json_api,
            links: {
              self: {
                href: 'http://example.com/posts',
                meta: {
                  stuff: 'value'
                }
              }
            }
          ).serializable_hash
          expected = {
            self: {
              href: 'http://example.com/posts',
              meta: {
                stuff: 'value'
              }
            }
          }
          assert_equal(expected, hash[:links])
        end

        def test_nil_toplevel_links
          hash = ActiveModelSerializers::SerializableResource.new(
            @post,
            adapter: :json_api,
            links: nil
          ).serializable_hash
          refute hash.key?(:links), 'No links key to be output'
        end

        def test_nil_toplevel_links_json_adapter
          hash = ActiveModelSerializers::SerializableResource.new(
            @post,
            adapter: :json,
            links: nil
          ).serializable_hash
          refute hash.key?(:links), 'No links key to be output'
        end

        def test_resource_links
          hash = serializable(@author, adapter: :json_api).serializable_hash
          expected = {
            self: {
              href: 'http://example.com/link_author/1337',
              meta: {
                stuff: 'value'
              }
            },
            author: 'http://example.com/link_authors/1337',
            :"link-authors" => 'http://example.com/link_authors',
            resource: 'http://example.com/resource',
            posts: 'http://example.com/link_authors/1337/posts',
            :"yet-another" => 'http://example.com/resource/1337'
          }
          assert_equal(expected, hash[:data][:links])
        end
      end
    end
  end
end
