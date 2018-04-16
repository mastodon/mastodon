require 'test_helper'

module Elasticsearch
  module Test
    class SnapshotCreateRepositoryTest < ::Test::Unit::TestCase

      context "Snapshot: Create repository" do
        subject { FakeClient.new }

        should "require the :repository argument" do
          assert_raise ArgumentError do
            subject.snapshot.create_repository :body => {}
          end
        end

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.snapshot.create_repository :repository => 'foo'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal '_snapshot/foo', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.create_repository :repository => 'foo', :body => {}
        end

      end

    end
  end
end
