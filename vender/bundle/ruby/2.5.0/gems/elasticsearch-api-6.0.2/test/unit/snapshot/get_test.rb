require 'test_helper'

module Elasticsearch
  module Test
    class SnapshotGetTest < ::Test::Unit::TestCase

      context "Snapshot: Get" do
        subject { FakeClient.new }

        should "require the :repository argument" do
          assert_raise ArgumentError do
            subject.snapshot.get :snapshot => 'bar', :body => {}
          end
        end

        should "require the :snapshot argument" do
          assert_raise ArgumentError do
            subject.snapshot.get :repository => 'foo', :body => {}
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_snapshot/foo/bar', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.snapshot.get :repository => 'foo', :snapshot => 'bar'
        end

      end

    end
  end
end
