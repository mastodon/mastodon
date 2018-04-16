require 'test_helper'

module Elasticsearch
  module Test
    class MsearchTemplateTest < ::Test::Unit::TestCase

      context "Msearch Template" do
        subject { FakeClient.new }

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.msearch
          end
        end

        should "serialize and post header/data pairs" do
          subject.expects(:perform_request).with do |method, url, params, body, headers|
            assert_equal 'GET', method
            assert_equal '_msearch/template', url
            assert_equal Hash.new, params
            assert_equal <<-PAYLOAD.gsub(/^\s+/, ''), body
            {"index":"foo"}
            {"inline":{"query":{"match":{"foo":"{{q}}"}}},"params":{"q":"foo"}}
            {"index":"bar"}
            {"id":"query_foo","params":{"q":"foo"}}
            PAYLOAD
            assert_equal 'application/x-ndjson', headers["Content-Type"]
            true
          end.returns(FakeResponse.new)

          subject.msearch_template :body => [
            { :index => 'foo' },
            { :inline => { :query => { :match => { :foo => '{{q}}' } } }, :params => { :q => 'foo' } },
            { :index => 'bar' },
            { :id => 'query_foo', :params => { :q => 'foo' } }
          ]
        end

        should "post a string payload intact" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal %Q|{"foo":"bar"}\n{"moo":"lam"}|, body
            true
          end.returns(FakeResponse.new)

          subject.msearch_template :body => %Q|{"foo":"bar"}\n{"moo":"lam"}|
        end

        should "perform request against an index" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/_msearch/template', url
            true
          end.returns(FakeResponse.new)

          subject.msearch_template :index => 'foo', :body => []
        end

      end

    end
  end
end
