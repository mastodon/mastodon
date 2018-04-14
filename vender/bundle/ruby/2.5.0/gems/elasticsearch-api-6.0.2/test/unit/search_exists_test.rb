require 'test_helper'

module Elasticsearch
  module Test
    class SearchExistsTest < ::Test::Unit::TestCase

      context "Search exists" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_search/exists', url
            assert_equal 'foo', params[:q]
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.search_exists :q => 'foo'
        end

      end

    end
  end
end
