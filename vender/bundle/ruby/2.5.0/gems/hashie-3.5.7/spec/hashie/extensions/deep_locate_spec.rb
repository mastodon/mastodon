require 'spec_helper'
require 'active_support/core_ext/hash/indifferent_access'

describe Hashie::Extensions::DeepLocate do
  let(:hash) do
    {
      from: 0,
      size: 25,
      query: {
        bool: {
          must: [
            {
              query_string: {
                query: 'foobar',
                default_operator: 'AND',
                fields: [
                  'title^2',
                  '_all'
                ]
              }
            },
            {
              match: {
                field_1: 'value_1'
              }
            },
            {
              range: {
                lsr09: {
                  gte: 2014
                }
              }
            }
          ],
          should: [
            {
              match: {
                field_2: 'value_2'
              }
            }
          ],
          must_not: [
            {
              range: {
                lsr10: {
                  gte: 2014
                }
              }
            }
          ]
        }
      }
    }
  end

  describe '.deep_locate' do
    context 'if called with a non-callable comparator' do
      it 'creates a key comparator on-th-fly' do
        expect(described_class.deep_locate(:lsr10, hash)).to eq([hash[:query][:bool][:must_not][0][:range]])
      end
    end

    it 'locates enumerables for which the given comparator returns true for at least one element' do
      examples = [
        [
          ->(key, _value, _object) { key == :fields },
          [
            hash[:query][:bool][:must].first[:query_string]
          ]
        ],
        [
          ->(_key, value, _object) { value.is_a?(String) && value.include?('value') },
          [
            hash[:query][:bool][:must][1][:match],
            hash[:query][:bool][:should][0][:match]
          ]
        ],
        [
          lambda do |_key, _value, object|
            object.is_a?(Array) &&
            !object.extend(described_class).deep_locate(:match).empty?
          end,
          [
            hash[:query][:bool][:must],
            hash[:query][:bool][:should]
          ]
        ]
      ]

      examples.each do |comparator, expected_result|
        expect(described_class.deep_locate(comparator, hash)).to eq(expected_result)
      end
    end

    it 'returns an empty array if nothing was found' do
      expect(described_class.deep_locate(:muff, foo: 'bar')).to eq([])
    end
  end

  context 'if extending an existing object' do
    let(:extended_hash) do
      hash.extend(described_class)
    end

    it 'adds #deep_locate' do
      expect(extended_hash.deep_locate(:bool)).to eq([hash[:query]])
    end
  end

  context 'if included in a hash' do
    let(:derived_hash_with_extension_included) do
      Class.new(Hash) do
        include Hashie::Extensions::DeepLocate
      end
    end

    let(:instance) do
      derived_hash_with_extension_included.new.update(hash)
    end

    it 'adds #deep_locate' do
      expect(instance.deep_locate(:bool)).to eq([hash[:query]])
    end
  end

  context 'on an ActiveSupport::HashWithIndifferentAccess' do
    let(:instance) { hash.dup.with_indifferent_access }

    it 'can locate symbolic keys' do
      expect(described_class.deep_locate(:lsr10, instance)).to eq ['lsr10' => { 'gte' => 2014 }]
    end

    it 'can locate string keys' do
      expect(described_class.deep_locate('lsr10', instance)).to eq ['lsr10' => { 'gte' => 2014 }]
    end
  end
end
