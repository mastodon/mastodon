require 'test_helper'

module Elasticsearch
  module Test
    class IngestSimulateTest < ::Test::Unit::TestCase

      context "Ingest: Simulate" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_ingest/pipeline/_simulate', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.ingest.simulate :body => {}
        end

        should "perform correct request with a pipeline ID" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_ingest/pipeline/foo/_simulate', url
            true
          end.returns(FakeResponse.new)

          subject.ingest.simulate :id => 'foo', :body => {}
        end

      end

    end
  end
end
