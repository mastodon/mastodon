require 'test_helper'

module Elasticsearch
  module Test
    class FieldCapsTest < ::Test::Unit::TestCase

      context "Field caps" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal 'foo/_field_caps', url
            assert_equal 'bar', params[:fields]
            assert_equal nil, body
            true
          end.returns(FakeResponse.new)

          subject.field_caps index: 'foo', fields: 'bar'
        end

      end

    end
  end
end
