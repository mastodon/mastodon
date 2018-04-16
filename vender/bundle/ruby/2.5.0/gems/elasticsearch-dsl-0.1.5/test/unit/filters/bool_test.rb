require 'test_helper'

module Elasticsearch
  module Test
    module Filters
      class BoolTest < ::Test::Unit::TestCase
        include Elasticsearch::DSL::Search::Filters

        context "Bool Filter" do
          subject { Bool.new }

          should "be converted to a Hash" do
            assert_equal({ bool: {} }, subject.to_hash)
          end

          should "take a Hash" do
            subject = Bool.new must: [ {term: { foo: 'bar' } } ]

            assert_equal( { bool: { must: [ {term: { foo: 'bar' } } ] } }, subject.to_hash )
          end

          should "take a block" do
            subject = Bool.new do
              must { term foo: 'bar' }
            end

            assert_equal( { bool: { must: [ {term: { foo: 'bar' }} ] } }, subject.to_hash )
          end

          should "take a block with multiple methods" do
            subject = Bool.new do
              must     { term foo: 'bar' }
              must_not { term moo: 'bam' }
              should   { term xoo: 'bax' }
            end

            assert_equal( { bool:
                            { must:     [ {term: { foo: 'bar' }} ],
                              must_not: [ {term: { moo: 'bam' }} ],
                              should:   [ {term: { xoo: 'bax' }} ]
                            }
                          },
                          subject.to_hash )
          end

          should "take a block with multiple conditions" do
            subject = Bool.new do
              must { term foo: 'bar' }
              must { term moo: 'bam' }

              should { term xoo: 'bax' }
              should { term zoo: 'baz' }
            end

            # Make sure we're not additive
            subject.to_hash
            subject.to_hash

            assert_equal( { bool:
                            { must:     [ {term: { foo: 'bar' }}, {term: { moo: 'bam' }} ],
                              should:   [ {term: { xoo: 'bax' }}, {term: { zoo: 'baz' }} ]
                            }
                          },
                          subject.to_hash )
          end

          should "take method calls" do
            subject = Bool.new

            subject.must { term foo: 'bar' }
            assert_equal( { bool: { must: [ {term: { foo: 'bar' }} ] } }, subject.to_hash )

            subject.must { term moo: 'bam' }
            assert_equal( { bool: { must: [ {term: { foo: 'bar' }}, {term: { moo: 'bam' }} ]} },
                          subject.to_hash )

            subject.should { term xoo: 'bax' }
            assert_equal( { bool:
                            { must:   [ {term: { foo: 'bar' }}, {term: { moo: 'bam' }} ],
                              should: [ {term: { xoo: 'bax' }} ] }
                          },
                          subject.to_hash )
          end

          should "be chainable" do
            subject = Bool.new

            assert_instance_of Bool, subject.must     { term foo: 'bar' }
            assert_instance_of Bool, subject.must     { term foo: 'bar' }.must { term moo: 'bam' }
            assert_instance_of Bool, subject.must_not { term foo: 'bar' }
            assert_instance_of Bool, subject.should   { term foo: 'bar' }
          end

        end
      end
    end
  end
end
