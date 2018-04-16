require 'test_helper'

module Elasticsearch
  module Test
    class SearchTemplateTest < ::Test::Unit::TestCase

      context "Search template" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo/_search/template', url
            assert_equal Hash.new, params
            assert_equal 'bar', body[:foo]
            true
          end.returns(FakeResponse.new)

          subject.search_template :index => 'foo', :body => { :foo => 'bar' }
        end

      end

    end
  end
end
