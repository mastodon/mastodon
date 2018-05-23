require 'test_helper'

module Elasticsearch
  module Test
    class SnapshotGetRepositoryTest < ::Test::Unit::TestCase

      context "Snapshot: Get repository" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_snapshot/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.get_repository :repository => 'foo'
        end

      end

    end
  end
end
