require 'test_helper'

module Elasticsearch
  module Test
    module Aggregations
      class SignificantTermsTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Aggregations

        context "SignificantTerms aggregation" do
          subject { SignificantTerms.new }

          should "be converted to a Hash" do
            assert_equal({ significant_terms: {} }, subject.to_hash)
          end

          should "have option methods" do
            subject = SignificantTerms.new

            subject.field 'bar'
            subject.size 'bar'
            subject.shard_size 'bar'
            subject.min_doc_count 'bar'
            subject.shard_min_doc_count 'bar'
            subject.include 'bar'
            subject.exclude 'bar'
            subject.background_filter 'bar'
            subject.mutual_information 'bar'
            subject.chi_square 'bar'
            subject.gnd 'bar'

            assert_equal %w[ background_filter chi_square exclude field gnd include min_doc_count mutual_information shard_min_doc_count shard_size size ],
                         subject.to_hash[:significant_terms].keys.map(&:to_s).sort
            assert_equal 'bar', subject.to_hash[:significant_terms][:field]
          end

          should "take a block" do
            subject = SignificantTerms.new do
              field 'bar'
            end
            assert_equal({significant_terms: { field: 'bar' } }, subject.to_hash)
          end
        end
      end
    end
  end
end
