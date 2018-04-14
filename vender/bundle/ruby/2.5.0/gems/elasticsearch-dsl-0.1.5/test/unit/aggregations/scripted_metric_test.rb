require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class ScriptedMetricTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "ScriptedMetric agg" do
          subject { ScriptedMetric.new }

          should "be converted to a Hash" do
            assert_equal({ scripted_metric: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = ScriptedMetric.new

            subject.init_script 'bar'
            subject.map_script 'bar'
            subject.combine_script 'bar'
            subject.reduce_script 'bar'
            subject.params 'bar'
            subject.lang 'bar'

            assert_equal %w[ combine_script init_script lang map_script params reduce_script ],
                         subject.to_hash[:scripted_metric].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:scripted_metric][:init_script]
          end

          should "take a block" do
            subject = ScriptedMetric.new do
              init_script 'bar'
            end
            assert_equal({scripted_metric: { init_script: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
