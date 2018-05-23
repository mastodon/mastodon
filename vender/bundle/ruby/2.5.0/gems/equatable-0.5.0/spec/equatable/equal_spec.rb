# encoding: utf-8

require 'spec_helper'

describe Equatable, '#==' do
  let(:name) { 'Value' }
  let(:value) { 11 }

  let(:super_klass) {
    ::Class.new do
      include Equatable

      attr_reader :value

      def initialize(value)
        @value = value
      end
    end
  }

  let(:klass) { Class.new(super_klass) }

  let(:object) { klass.new(value) }

  subject { object == other }

  context 'with the same object' do
    let(:other) { object }

    it { is_expected.to eql(true) }

    it 'is symmetric' do
      is_expected.to eql(other == object)
    end
  end

  context 'with an equivalent object' do
    let(:other) { object.dup }

    it { is_expected.to eql(true) }

    it 'is symmetric' do
      is_expected.to eql(other == object)
    end
  end

  context 'with an equivalent object of a subclass' do
    let(:other) { ::Class.new(klass).new(value) }

    it { is_expected.to eql(true) }

    it 'is not symmetric' do
      # LSP, any equality for type should work for subtype but
      # not the other way
      is_expected.not_to eql(other == object)
    end
  end

  context 'with an equivalent object of a superclass' do
    let(:other) { super_klass.new(value) }

    it { is_expected.to eql(false) }

    it 'is not symmetric' do
      is_expected.not_to eql(other == object)
    end
  end

  context 'with an object with a different interface' do
    let(:other) { Object.new }

    it { is_expected.to eql(false) }
  end

  context 'with an object of another class' do
    let(:other) { Class.new.new }

    it { is_expected.to eql(false) }

    it 'is symmetric' do
      is_expected.to eql(other == object)
    end
  end
end
