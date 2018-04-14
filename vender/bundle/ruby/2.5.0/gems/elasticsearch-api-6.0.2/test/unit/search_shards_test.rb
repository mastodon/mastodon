require 'test_helper'

module Elasticsearch
  module Test
    class SearchShardsTest < ::Test::Unit::TestCase

      context "Search shards" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_search_shards', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.search_shards
        end

      end

    end
  end
end
