require 'test_helper'

module Elasticsearch
  module Test
    class TermvectorsTest < ::Test::Unit::TestCase

      context "Termvectors" do
        subject { FakeClient.new }

        should "require the :index argument" do
          assert_raise ArgumentError do
            subject.termvectors :type => 'bar', :id => '1'
          end
        end

        should "require the :type argument" do
          assert_raise ArgumentError do
            subject.termvectors :index => 'foo', :id => '1'
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo/bar/123/_termvectors', url
            assert_equal Hash.new, params
            assert_equal Hash.new, body
            true
          end.returns(FakeResponse.new)

          subject.termvectors :index => 'foo', :type => 'bar', :id => '123', :body => {}
        end

        should "be aliased to singular for older versions" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'foo/bar/123/_termvector', url
            true
          end.returns(FakeResponse.new)

          subject.termvector :index => 'foo', :type => 'bar', :id => '123'
        end

      end

    end
  end
end
