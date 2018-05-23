require 'test_helper'

module Elasticsearch
  module Test
    class RenderSearchTemplateTest < ::Test::Unit::TestCase

      context "Render search template" do
        subject { FakeClient.new }

        should "perform correct request" do
          subject.expects(:perform_request).with do |method, url, params, body|
            assert_equal 'GET', method
            assert_equal '_render/template', url
            assert_equal({ :id => 'foo' }, params)
            assert_equal({ :foo => 'bar' }, body)
            true
          end.returns(FakeResponse.new)

          subject.render_search_template :id => 'foo', :body => { :foo => 'bar' }
        end
      end

    end
  end
end
