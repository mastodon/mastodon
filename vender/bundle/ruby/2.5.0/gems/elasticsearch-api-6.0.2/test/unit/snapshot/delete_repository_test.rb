require 'test_helper'

module Elasticsearch
  module Test
    class SnapshotDeleteRepositoryTest < ::Test::Unit::TestCase

      context "Snapshot: Delete repository" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'DELETE', method
            assert_equal '_snapshot/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.delete_repository :repository => 'foo'
        end

        should "perform the request for more indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_snapshot/foo,bar', url
            true
          end.returns(FakeResponse.new)

          subject.snapshot.delete_repository :repository => ['foo','bar']
        end

      end

    end
  end
end
