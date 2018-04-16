require 'test_helper'

module Elasticsearch
  module Test
    class IngestGetPipelineTest < ::Test::Unit::TestCase

      context "Ingest: Get pipeline" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_ingest/pipeline/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.ingest.get_pipeline :id => 'foo'
        end

        should "URL-escape the ID" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_ingest/pipeline/foo%5Ebar', url
            true
          end.returns(FakeResponse.new)

          subject.ingest.get_pipeline :id => 'foo^bar'
        end

      end

    end
  end
end
