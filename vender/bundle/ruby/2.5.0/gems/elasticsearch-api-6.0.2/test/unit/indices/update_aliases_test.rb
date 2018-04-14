require 'test_helper'

module Elasticsearch
  module Test
    class IndicesPutAliasesTest < ::Test::Unit::TestCase

      context "Indices: Update aliases" do
        subject { FakeClient.new }

        should "require the :body argument" do
          assert_raise ArgumentError do
            subject.indices.update_aliases
          end
        end

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'POST', method
            assert_equal '_aliases', url
            assert_equal Hash.new, params
            assert_equal [], body[:actions]
            true
          end.returns(FakeResponse.new)

          subject.indices.update_aliases :body => { :actions => [] }
        end

        should "pass the URL parameters" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal '_aliases', url
            assert_equal '1s', params[:timeout]
            true
          end.returns(FakeResponse.new)

          subject.indices.update_aliases :body => {}, :timeout => '1s'
        end

      end

    end
  end
end
