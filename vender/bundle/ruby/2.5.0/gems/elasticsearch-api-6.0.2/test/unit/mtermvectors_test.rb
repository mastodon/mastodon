require 'test_helper'

module Elasticsearch
  module Test
    class MtermvectorsTest < ::Test::Unit::TestCase

      context "Mtermvectors" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'my-index/my-type/_mtermvectors', url
            assert_equal Hash.new, params
            assert_equal [1, 2, 3], body[:ids]
            true
          end.returns(FakeResponse.new)

          subject.mtermvectors :index => 'my-index', :type => 'my-type', :body => { :ids => [1, 2, 3] }
        end

        should "allow passing a list of IDs instead of the body" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'my-index/my-type/_mtermvectors', url
            assert_equal Hash.new, params
            assert_equal [1, 2, 3], body[:ids]
            true
          end.returns(FakeResponse.new)

          subject.mtermvectors :index => 'my-index', :type => 'my-type', :ids => [1, 2, 3]
        end

      end

    end
  end
end
