require 'test_helper'

module Elasticsearch
  module Test
    class IngestPutPipelineTest < ::Test::Unit::TestCase

      context "Ingest: Put pipeline" do
        subject { FakeClient.new }

        should "require the :id argument" do
          assert_raise ArgumentError do
            subject.ingest.put_pipeline :body => {}
          end
        end

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.ingest.put_pipeline :id => 'foo'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal '_ingest/pipeline/foo', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.ingest.put_pipeline :id => 'foo', :body => {}
        end

        should "URL-escape the ID" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_ingest/pipeline/foo%5Ebar', url
            true
          end.returns(FakeResponse.new)

          subject.ingest.put_pipeline :id => 'foo^bar', :body => {}
        end
      end

    end
  end
end
