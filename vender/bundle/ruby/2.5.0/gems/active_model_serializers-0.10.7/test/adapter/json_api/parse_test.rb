require 'test_helper'
module ActiveModelSerializers
  module Adapter
    class JsonApi
      module Deserialization
        class ParseTest < Minitest::Test
          def setup
            @hash = {
              'data' => {
                'type' => 'photos',
                'id' => 'zorglub',
                'attributes' => {
                  'title' => 'Ember Hamster',
                  'src' => 'http://example.com/images/productivity.png'
                },
                'relationships' => {
                  'author' => {
                    'data' => nil
                  },
                  'photographer' => {
                    'data' => { 'type' => 'people', 'id' => '9' }
                  },
                  'comments' => {
                    'data' => [
                      { 'type' => 'comments', 'id' => '1' },
                      { 'type' => 'comments', 'id' => '2' }
                    ]
                  }
                }
              }
            }
            @params = ActionController::Parameters.new(@hash)
            @expected = {
              id: 'zorglub',
              title: 'Ember Hamster',
              src: 'http://example.com/images/productivity.png',
              author_id: nil,
              photographer_id: '9',
              comment_ids: %w(1 2)
            }

            @illformed_payloads = [nil,
                                   {},
                                   {
                                     'data' => nil
                                   }, {
                                     'data' => { 'attributes' => [] }
                                   }, {
                                     'data' => { 'relationships' => [] }
                                   }, {
                                     'data' => {
                                       'relationships' => { 'rel' => nil }
                                     }
                                   }, {
                                     'data' => {
                                       'relationships' => { 'rel' => {} }
                                     }
                                   }]
          end

          def test_hash
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash)
            assert_equal(@expected, parsed_hash)
          end

          def test_actioncontroller_parameters
            assert_equal(false, @params.permitted?)
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@params)
            assert_equal(@expected, parsed_hash)
          end

          def test_illformed_payloads_safe
            @illformed_payloads.each do |p|
              parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse(p)
              assert_equal({}, parsed_hash)
            end
          end

          def test_illformed_payloads_unsafe
            @illformed_payloads.each do |p|
              assert_raises(InvalidDocument) do
                ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(p)
              end
            end
          end

          def test_filter_fields_only
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash, only: [:id, :title, :author])
            expected = {
              id: 'zorglub',
              title: 'Ember Hamster',
              author_id: nil
            }
            assert_equal(expected, parsed_hash)
          end

          def test_filter_fields_except
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash, except: [:id, :title, :author])
            expected = {
              src: 'http://example.com/images/productivity.png',
              photographer_id: '9',
              comment_ids: %w(1 2)
            }
            assert_equal(expected, parsed_hash)
          end

          def test_keys
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash, keys: { author: :user, title: :post_title })
            expected = {
              id: 'zorglub',
              post_title: 'Ember Hamster',
              src: 'http://example.com/images/productivity.png',
              user_id: nil,
              photographer_id: '9',
              comment_ids: %w(1 2)
            }
            assert_equal(expected, parsed_hash)
          end

          def test_polymorphic
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash, polymorphic: [:photographer])
            expected = {
              id: 'zorglub',
              title: 'Ember Hamster',
              src: 'http://example.com/images/productivity.png',
              author_id: nil,
              photographer_id: '9',
              photographer_type: 'Person',
              comment_ids: %w(1 2)
            }
            assert_equal(expected, parsed_hash)
          end
        end
      end
    end
  end
end
