require 'test_helper'

module Elasticsearch
  module Test
    class SnapshotCreateTest < ::Test::Unit::TestCase

      context "Snapshot: Create" do
        subject { FakeClient.new }

        should "require the :repository argument" do
          assert_raise ArgumentError do
            subject.snapshot.create :snapshot => 'bar', :body => {}
          end
        end

        should "require the :snapshot argument" do
          assert_raise ArgumentError do
            subject.snapshot.create :repository => 'foo', :body => {}
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal '_snapshot/foo/bar', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.create :repository => 'foo', :snapshot => 'bar', :body => {}
        end

      end

    end
  end
end
