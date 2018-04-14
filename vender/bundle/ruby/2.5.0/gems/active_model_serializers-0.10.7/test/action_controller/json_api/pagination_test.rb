require 'test_helper'
require 'will_paginate/array'
require 'kaminari'
require 'kaminari/hooks'
::Kaminari::Hooks.init

module ActionController
  module Serialization
    class JsonApi
      class PaginationTest < ActionController::TestCase
        KAMINARI_URI = 'http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_kaminari'.freeze
        WILL_PAGINATE_URI = 'http://test.host/action_controller/serialization/json_api/pagination_test/pagination_test/render_pagination_using_will_paginate'.freeze

        class PaginationTestController < ActionController::Base
          def setup
            @array = [
              Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1'),
              Profile.new(name: 'Name 2', description: 'Description 2', comments: 'Comments 2'),
              Profile.new(name: 'Name 3', description: 'Description 3', comments: 'Comments 3')
            ]
          end

          def using_kaminari
            setup
            Kaminari.paginate_array(@array).page(params[:page][:number]).per(params[:page][:size])
          end

          def using_will_paginate
            setup
            @array.paginate(page: params[:page][:number], per_page: params[:page][:size])
          end

          def render_pagination_using_kaminari
            render json: using_kaminari, adapter: :json_api
          end

          def render_pagination_using_will_paginate
            render json: using_will_paginate, adapter: :json_api
          end

          def render_array_without_pagination_links
            setup
            render json: @array, adapter: :json_api
          end
        end

        tests PaginationTestController

        def test_render_pagination_links_with_will_paginate
          expected_links = { 'self' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=2&page%5Bsize%5D=1",
                             'first' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=1",
                             'prev' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=1",
                             'next' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1",
                             'last' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1" }

          get :render_pagination_using_will_paginate, params: { page: { number: 2, size: 1 } }
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_render_only_first_last_and_next_pagination_links
          expected_links = { 'self' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
                             'first' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2",
                             'prev' => nil,
                             'next' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2",
                             'last' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2" }
          get :render_pagination_using_will_paginate, params: { page: { number: 1, size: 2 } }
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_render_pagination_links_with_kaminari
          expected_links = { 'self' => "#{KAMINARI_URI}?page%5Bnumber%5D=2&page%5Bsize%5D=1",
                             'first' => "#{KAMINARI_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=1",
                             'prev' => "#{KAMINARI_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=1",
                             'next' => "#{KAMINARI_URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1",
                             'last' => "#{KAMINARI_URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1" }
          get :render_pagination_using_kaminari, params: { page: { number: 2, size: 1 } }
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_render_only_prev_first_and_last_pagination_links
          expected_links = { 'self' => "#{KAMINARI_URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1",
                             'first' => "#{KAMINARI_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=1",
                             'prev' => "#{KAMINARI_URI}?page%5Bnumber%5D=2&page%5Bsize%5D=1",
                             'next' => nil,
                             'last' => "#{KAMINARI_URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1" }
          get :render_pagination_using_kaminari, params: { page: { number: 3, size: 1 } }
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_render_only_first_last_and_next_pagination_links_with_additional_params
          expected_links = { 'self' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2&teste=additional",
                             'first' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=2&teste=additional",
                             'prev' => nil,
                             'next' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2&teste=additional",
                             'last' => "#{WILL_PAGINATE_URI}?page%5Bnumber%5D=2&page%5Bsize%5D=2&teste=additional" }
          get :render_pagination_using_will_paginate, params: { page: { number: 1, size: 2 }, teste: 'additional' }
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_render_only_prev_first_and_last_pagination_links_with_additional_params
          expected_links = { 'self' => "#{KAMINARI_URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1&teste=additional",
                             'first' => "#{KAMINARI_URI}?page%5Bnumber%5D=1&page%5Bsize%5D=1&teste=additional",
                             'prev' => "#{KAMINARI_URI}?page%5Bnumber%5D=2&page%5Bsize%5D=1&teste=additional",
                             'next' => nil,
                             'last' => "#{KAMINARI_URI}?page%5Bnumber%5D=3&page%5Bsize%5D=1&teste=additional" }
          get :render_pagination_using_kaminari, params: { page: { number: 3, size: 1 }, teste: 'additional' }
          response = JSON.parse(@response.body)
          assert_equal expected_links, response['links']
        end

        def test_array_without_pagination_links
          get :render_array_without_pagination_links, params: { page: { number: 2, size: 1 } }
          response = JSON.parse(@response.body)
          refute response.key? 'links'
        end
      end
    end
  end
end
