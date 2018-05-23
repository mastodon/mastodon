require 'test_helper'

module Elasticsearch
  module Test
    class DSLTest < ::Test::Unit::TestCase
      context "The DSL" do
        class DummyDSLReceiver
          include Elasticsearch::DSL
        end

        should "include the module in receiver" do
          assert_contains DummyDSLReceiver.included_modules, Elasticsearch::DSL
          assert_contains DummyDSLReceiver.included_modules, Elasticsearch::DSL::Search
        end
      end
    end
  end
end
