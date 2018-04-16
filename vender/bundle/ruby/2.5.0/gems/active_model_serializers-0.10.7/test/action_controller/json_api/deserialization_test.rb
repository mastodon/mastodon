require 'test_helper'

module ActionController
  module Serialization
    class JsonApi
      class DeserializationTest < ActionController::TestCase
        class DeserializationTestController < ActionController::Base
          def render_parsed_payload
            parsed_hash = ActiveModelSerializers::Deserialization.jsonapi_parse(params)
            render json: parsed_hash
          end

          def render_polymorphic_parsed_payload
            parsed_hash = ActiveModelSerializers::Deserialization.jsonapi_parse(
              params,
              polymorphic: [:restriction_for, :restricted_to]
            )
            render json: parsed_hash
          end
        end

        tests DeserializationTestController

        def test_deserialization_of_relationship_only_object
          hash = {
            'data' => {
              'type' => 'restraints',
              'relationships' => {
                'restriction_for' => {
                  'data' => {
                    'type' => 'discounts',
                    'id' => '67'
                  }
                },
                'restricted_to' => {
                  'data' => nil
                }
              }
            },
            'restraint' => {}
          }

          post :render_polymorphic_parsed_payload, params: hash

          response = JSON.parse(@response.body)
          expected = {
            'restriction_for_id' => '67',
            'restriction_for_type' => 'Discount',
            'restricted_to_id' => nil,
            'restricted_to_type' => nil
          }

          assert_equal(expected, response)
        end

        def test_deserialization
          hash = {
            'data' => {
              'type' => 'photos',
              'id' => 'zorglub',
              'attributes' => {
                'title' => 'Ember Hamster',
                'src' => 'http://example.com/images/productivity.png',
                'image-width' => '200',
                'imageHeight' => '200',
                'ImageSize' => '1024'
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
                },
                'related-images' => {
                  'data' => [
                    { 'type' => 'image', 'id' => '7' },
                    { 'type' => 'image', 'id' => '8' }
                  ]
                }
              }
            }
          }

          post :render_parsed_payload, params: hash

          response = JSON.parse(@response.body)
          expected = {
            'id' => 'zorglub',
            'title' => 'Ember Hamster',
            'src' => 'http://example.com/images/productivity.png',
            'image_width' => '200',
            'image_height' => '200',
            'image_size' => '1024',
            'author_id' => nil,
            'photographer_id' => '9',
            'comment_ids' => %w(1 2),
            'related_image_ids' => %w(7 8)
          }

          assert_equal(expected, response)
        end
      end
    end
  end
end
