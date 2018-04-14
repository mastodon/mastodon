require 'test_helper'

module Elasticsearch
  module Test
    class IngestDeletePipelineTest < ::Test::Unit::TestCase

      context "Ingest: Delete pipeline" do
        subject { FakeClient.new }

        should "require the :id argument" do
          assert_raise ArgumentError do
            subject.ingest.delete_pipeline
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'DELETE', method
            assert_equal '_ingest/pipeline/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.ingest.delete_pipeline :id => 'foo'
        end

        should "URL-escape the ID" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_ingest/pipeline/foo%5Ebar', url
            true
          end.returns(FakeResponse.new)

          subject.ingest.delete_pipeline :id => 'foo^bar'
        end

      end

    end
  end
end
