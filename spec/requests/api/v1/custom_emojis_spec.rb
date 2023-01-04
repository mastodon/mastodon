# frozen_string_literal: true
require 'swagger_helper'

RSpec.describe Api::V1::CustomEmojisController do
  path '/api/v1/custom_emojis' do
    get('list custom_emojis') do
      tags 'Api', 'V1', 'CustomEmojis'
      operationId 'v1CustomemojisListCustomEmoji'
      description 'Returns custom emojis that are available on the server.'
      rswag_json_endpoint
      let!(:custom_emojis) do
        [
          Fabricate(:custom_emoji, shortcode: 'test_emoji1', category: CustomEmojiCategory.create(name: 'test_category1')),
          Fabricate(:custom_emoji, shortcode: 'test_emoji2'),
          Fabricate(:custom_emoji, shortcode: 'test_emoji3', disabled: true),
          Fabricate(:custom_emoji, shortcode: 'test_emoji4', visible_in_picker: false),
        ]
      end

      response(200, 'successful') do
        schema type: :array, items: { '$ref' => '#/components/schemas/CustomEmoji' }
        rswag_add_examples!
        run_test! do |response|
          body = rswag_parse_body_sym(response)
          expect(body).to have_attributes(size: 2).and(
            match_array(
              [
                include({
                  shortcode: 'test_emoji1',
                  url: a_string_starting_with('http'),
                  static_url: a_string_starting_with('http'),
                  visible_in_picker: true,
                  category: 'test_category1',
                }),
                include({
                  shortcode: 'test_emoji2',
                  url: a_string_starting_with('http'),
                  static_url: a_string_starting_with('http'),
                  visible_in_picker: true,
                }),
              ]
            )
          )
        end
      end
    end
  end
end
