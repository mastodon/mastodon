require 'test_helper'

module ActionController
  module Serialization
    class JsonApi
      class ErrorsTest < ActionController::TestCase
        def test_active_model_with_multiple_errors
          get :render_resource_with_errors

          expected_errors_object = {
            errors:               [
              { source: { pointer: '/data/attributes/name' }, detail: 'cannot be nil' },
              { source: { pointer: '/data/attributes/name' }, detail: 'must be longer' },
              { source: { pointer: '/data/attributes/id' }, detail: 'must be a uuid' }
            ]
          }.to_json
          assert_equal json_response_body.to_json, expected_errors_object
        end

        def json_response_body
          JSON.load(@response.body)
        end

        class ErrorsTestController < ActionController::Base
          def render_resource_with_errors
            resource = Profile.new(name: 'Name 1',
                                   description: 'Description 1',
                                   comments: 'Comments 1')
            resource.errors.add(:name, 'cannot be nil')
            resource.errors.add(:name, 'must be longer')
            resource.errors.add(:id, 'must be a uuid')
            render json: resource, adapter: :json_api, serializer: ActiveModel::Serializer::ErrorSerializer
          end
        end

        tests ErrorsTestController
      end
    end
  end
end
