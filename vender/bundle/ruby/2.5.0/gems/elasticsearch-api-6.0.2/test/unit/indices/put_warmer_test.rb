require 'test_helper'

module Elasticsearch
  module Test
    class IndicesPutWarmerTest < ::Test::Unit::TestCase

      context "Indices: Put warmer" do
        subject { FakeClient.new }

        should "require the :name argument" do
          assert_raise ArgumentError do
            subject.indices.put_warmer :index => 'foo', :body => {}
          end
        end

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.indices.put_warmer :index => 'foo', :name => 'bar'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'PUT', method
            assert_equal 'foo/_warmer/bar', url
            assert_equal Hash.new, params
            assert_equal :match_all, body[:query].keys.first
            true
          end.returns(FakeResponse.new)

          subject.indices.put_warmer :index => 'foo', :name => 'bar', :body => { :query => { :match_all => {} } }
        end

        should "perform request against multiple indices" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo,bar/_warmer/xul', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_warmer :index => ['foo','bar'], :name => 'xul', :body => {}
        end

        should "perform request against an index and type" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/_warmer/xul', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_warmer :index => 'foo', :type => 'bar', :name => 'xul', :body => {}
        end

        should "URL-escape the parts" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo%5Ebar/bar%2Fbam/_warmer/qu+uz', url
            true
          end.returns(FakeResponse.new)

          subject.indices.put_warmer :index => 'foo^bar', :type => 'bar/bam', :name => 'qu uz', :body => {}
        end

      end

    end
  end
end
