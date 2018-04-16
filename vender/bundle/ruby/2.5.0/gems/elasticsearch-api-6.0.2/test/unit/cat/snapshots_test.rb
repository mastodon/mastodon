require 'test_helper'

module Elasticsearch
  module Test
    class CatSnapshotsTest < ::Test::Unit::TestCase

      context "Cat: Snapshots" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat/snapshots/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.snapshots :repository => 'foo'
        end

      end

    end
  end
end
