require 'test_helper'

module Elasticsearch
  module Test
    class SnapshotVerifyRepositoryTest < ::Test::Unit::TestCase

      context "Snapshot: Verify repository" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_snapshot/foo/_verify', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.verify_repository :repository => 'foo'
        end

      end

    end
  end
end
