require 'test_helper'

module Elasticsearch
  module Test
    class HighlightTest < ::Test::Unit::TestCase
      context "Search highlight" do
        subject { Elasticsearch::DSL::Search::Highlight.new }

        should "take a Hash" do
          subject  = Elasticsearch::DSL::Search::Highlight.new fields: { 'foo' => {} }, pre_tags: ['*'], post_tags: ['*']

          assert_equal({ fields: { 'foo' => {} }, pre_tags: ['*'], post_tags: ['*'] }, subject.to_hash)
        end

        should "encode fields as an array" do
          subject.fields ['foo', 'bar']
          assert_equal({ fields: { foo: {}, bar: {} } }, subject.to_hash)
        end

        should "encode fields as a Hash" do
          subject.fields foo: { bar: 1 }, xoo: { bar: 2 }
          assert_equal({ fields: { foo: { bar: 1 }, xoo: { bar: 2 } } }, subject.to_hash)
        end

        should "encode a field" do
          subject.field 'foo'
          assert_equal({ fields: { foo: {} } }, subject.to_hash)
        end

        should "be additive on multiple calls" do
          subject.fields ['foo', 'bar']
          subject.field  'bam'
          subject.field  'baz', { xoo: 10 }
          assert_equal({ fields: { foo: {}, bar: {}, bam: {}, baz: { xoo: 10 } } }, subject.to_hash)
        end

        should "encode pre_tags" do
          subject.pre_tags '*'
          assert_equal({ pre_tags: ['*'] }, subject.to_hash)
        end

        should "encode post_tags" do
          subject.post_tags '*'
          assert_equal({ post_tags: ['*'] }, subject.to_hash)
        end

        should "encode pre_tags as an array" do
          subject.pre_tags ['*', '**']
          assert_equal({ pre_tags: ['*', '**'] }, subject.to_hash)
        end

        should "encode post_tags as an array" do
          subject.post_tags ['*', '**']
          assert_equal({ post_tags: ['*', '**'] }, subject.to_hash)
        end

        should "encode the encoder option" do
          subject.encoder 'foo'
          assert_equal({ encoder: 'foo' }, subject.to_hash)
        end

        should "encode the tags_schema option" do
          subject.tags_schema 'foo'
          assert_equal({ tags_schema: 'foo' }, subject.to_hash)
        end

        should "combine the options" do
          subject.fields ['foo', 'bar']
          subject.field  'bam'
          subject.pre_tags '*'
          subject.post_tags '*'
          assert_equal({ fields: { foo: {}, bar: {}, bam: {} }, pre_tags: ['*'], post_tags: ['*'] }, subject.to_hash)
        end
      end
    end
  end
end
