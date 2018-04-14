require 'test_helper'

module Elasticsearch
  module Test
    class SnapshotStatusTest < ::Test::Unit::TestCase

      context "Snapshot: Status" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_snapshot/_status', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.status
        end

        should "encode repository and snapshot" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_snapshot/foo/bar/_status', url
            assert_equal Hash.new, params
            assert_equal nil, body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.status :repository => 'foo', :snapshot => 'bar'
        end

      end

    end
  end
end
