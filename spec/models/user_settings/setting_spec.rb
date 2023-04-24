# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSettings::Setting do
  subject { described_class.new(name, options) }

  let(:name)      { :foo }
  let(:options)   { { default: default, namespace: namespace } }
  let(:default)   { false }
  let(:namespace) { nil }

  describe '#default_value' do
    context 'when default value is a primitive value' do
      it 'returns default value' do
        expect(subject.default_value).to eq default
      end
    end

    context 'when default value is a proc' do
      let(:default) { -> { 'bar' } }

      it 'returns value from proc' do
        expect(subject.default_value).to eq 'bar'
      end
    end
  end

  describe '#type' do
    it 'returns a type' do
      expect(subject.type).to be_a ActiveModel::Type::Value
    end

    context 'when default value is a boolean' do
      let(:default) { false }

      it 'returns boolean' do
        expect(subject.type).to be_a ActiveModel::Type::Boolean
      end
    end

    context 'when default value is a string' do
      let(:default) { '' }

      it 'returns string' do
        expect(subject.type).to be_a ActiveModel::Type::String
      end
    end

    context 'when default value is a lambda returning a boolean' do
      let(:default) { -> { false } }

      it 'returns boolean' do
        expect(subject.type).to be_a ActiveModel::Type::Boolean
      end
    end

    context 'when default value is a lambda returning a string' do
      let(:default) { -> { '' } }

      it 'returns boolean' do
        expect(subject.type).to be_a ActiveModel::Type::String
      end
    end
  end

  describe '#type_cast' do
    context 'when default value is a boolean' do
      let(:default) { false }

      it 'returns boolean' do
        expect(subject.type_cast('1')).to be true
      end
    end

    context 'when default value is a string' do
      let(:default) { '' }

      it 'returns string' do
        expect(subject.type_cast(1)).to eq '1'
      end
    end
  end

  describe '#to_a' do
    it 'returns an array' do
      expect(subject.to_a).to eq [name, default]
    end
  end

  describe '#key' do
    context 'when there is no namespace' do
      it 'returnsn a symbol' do
        expect(subject.key).to eq :foo
      end
    end

    context 'when there is a namespace' do
      let(:namespace) { :bar }

      it 'returns a symbol' do
        expect(subject.key).to eq :'bar.foo'
      end
    end
  end
end
