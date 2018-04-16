require 'test_helper'

module Elasticsearch
  module Test
    class PingTest < ::Test::Unit::TestCase

      context "Ping" do
        subject { FakeClient.new }

         should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'HEAD', method
            assert_equal '', url
            assert_equal Hash.new, params
            assert_nil   body
            true
          end.returns(FakeResponse.new)

          subject.ping
        end

        should "return true for successful response" do
          subject.expects(:perform_request).returns(FakeResponse.new 200, 'OK')
          assert_equal true, subject.ping
        end

        should "return false for 404 response" do
          subject.expects(:perform_request).returns(FakeResponse.new 404, 'Not Found')
          assert_equal false, subject.ping
        end

        should "return false on 'not found' exceptions" do
          subject.expects(:perform_request).raises(StandardError.new '404 NotFound')
          assert_equal false, subject.ping
        end

        should "return false on 'connection failed' exceptions" do
          subject.expects(:perform_request).raises(StandardError.new 'ConnectionFailed')
          assert_equal false, subject.ping
        end

        should "re-raise generic exceptions" do
          subject.expects(:perform_request).raises(StandardError)
          assert_raise(StandardError) do
            assert_equal false, subject.ping
          end
        end

      end

    end
  end
end
