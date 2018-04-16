require 'test_helper'

module Elasticsearch
  module Test
    class CatFielddataTest < ::Test::Unit::TestCase

      context "Cat: Fielddata" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat/fielddata', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.fielddata
        end

        should "pass the fields in the URL" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_cat/fielddata/foo,bar', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.cat.fielddata :fields => ['foo', 'bar']
        end

      end

    end
  end
end
