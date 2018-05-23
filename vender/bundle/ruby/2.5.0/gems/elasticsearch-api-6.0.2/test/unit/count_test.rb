require 'test_helper'

module Elasticsearch
  module Test
    class CountTest < ::Test::Unit::TestCase

      context "Count" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_count', url
            assert_equal Hash.new, params
            assert_nil body
            true
          end.returns(FakeResponse.new)

          subject.count
        end

        should "encode indices and types" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo,bar/t1,t2/_count', url
            true
          end.returns(FakeResponse.new)

          subject.count :index => ['foo','bar'], :type => ['t1','t2']
        end

        should "take the query" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal( {:match => {:foo => 'bar'}}, body)
            true
          end.returns(FakeResponse.new)

          subject.count :body => { :match => { :foo => 'bar' } }
        end

      end

    end
  end
end
