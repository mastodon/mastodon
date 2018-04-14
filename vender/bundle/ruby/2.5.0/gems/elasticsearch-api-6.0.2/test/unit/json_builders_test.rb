require 'test_helper'

require 'jbuilder' if defined?(RUBY_VERSION) && RUBY_VERSION > '1.9'
require 'jsonify'

module Elasticsearch
  module Test
    class JsonBuildersTest < ::Test::Unit::TestCase

      context "JBuilder" do
        subject { FakeClient.new }

        should "build a JSON" do
          subject.expects(:perform_request).with do |method, url, params, body|
            json = MultiJson.load(body)

            assert_instance_of String, body
            assert_equal       'test', json['query']['match']['title']['query']
            true
          end.returns(FakeResponse.new)

          json = Jbuilder.encode do |json|
                   json.query do
                     json.match do
                       json.title do
                         json.query    'test'
                       end
                     end
                   end
                 end

          subject.search :body => json
        end
      end if defined?(RUBY_VERSION) && RUBY_VERSION > '1.9'

      context "Jsonify" do
        subject { FakeClient.new }

        should "build a JSON" do
          subject.expects(:perform_request).with do |method, url, params, body|
            json = MultiJson.load(body)

            assert_instance_of String, body
            assert_equal       'test', json['query']['match']['title']['query']
            true
          end.returns(FakeResponse.new)

          json = Jsonify::Builder.compile do |json|
                   json.query do
                     json.match do
                       json.title do
                         json.query    'test'
                       end
                     end
                   end
                 end

          subject.search :body => json
        end
      end

    end
  end
end
