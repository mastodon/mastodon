require 'test_helper'

module Elasticsearch
  module Test
    class IndicesGetFieldMappingTest < ::Test::Unit::TestCase

      context "Indices: Get field mapping" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_mapping/field/foo', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.indices.get_field_mapping :field => 'foo'
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_mapping/field/bam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_field_mapping :index => 'foo', :field => 'bam'
        end

        should "perform request against an index and type" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_mapping/bar/field/bam', url
            true
          end.returns(FakeResponse.new)

          subject.indices.get_field_mapping :index => 'foo', :type => 'bar', :field => 'bam'
        end

      end

    end
  end
end
