require 'test_helper'

module Elasticsearch
  module Test
    class MpercolateTest < ::Test::Unit::TestCase

      context "Mpercolate" do
        subject { FakeClient.new }

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.mpercolate
          end
        end

        should "post correct payload to the endpoint" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_mpercolate', url
            assert_equal Hash.new, params

            lines = body.split("\n")
            assert_match /\{"percolate"/, lines[0]
            assert_match /\{"doc"/,       lines[1]
            assert_match /\{"percolate"/, lines[2]
            assert_match /\{\}/,          lines[3]
            true
          end.returns(FakeResponse.new)

          subject.mpercolate :body => [
            { :percolate => { :index => "my-index", :type => "my-type" } },
            { :doc => { :message => "foo bar" } },
            { :percolate => { :index => "my-other-index", :type => "my-other-type", :id => "1" } },
            { }
          ]
        end

        should "post a string payload intact" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal %Q|{"foo":"bar"}\n{"moo":"lam"}|, body
            true
          end.returns(FakeResponse.new)

          subject.mpercolate :body => %Q|{"foo":"bar"}\n{"moo":"lam"}|
        end

      end

    end
  end
end
