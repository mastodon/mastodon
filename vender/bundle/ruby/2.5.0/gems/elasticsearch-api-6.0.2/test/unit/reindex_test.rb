require 'test_helper'

module Elasticsearch
  module Test
    class ReindexTest < ::Test::Unit::TestCase

      context "Reindex" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_reindex', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.reindex :body => {}
        end

      end

    end
  end
end
