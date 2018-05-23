require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class ScriptTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Script filter" do
          subject { Script.new }

          should "be converted to a Hash" do
            assert_equal({ script: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = Script.new :foo

            subject.script 'bar'
            subject.params foo: 'bar'

            assert_equal %w[ params script ],
                         subject.to_hash[:script][:foo].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:script][:foo][:script]
            assert_equal 'bar', subject.to_hash[:script][:foo][:params][:foo]
          end

          should "take a block" do
            subject = Script.new :foo do
              script 'bar'
            end
            assert_equal({script: { foo: { script: 'bar' } }}, subject.to_hash)
          end
        end
      end
    end
  end
end
