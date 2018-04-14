# encoding: utf-8

require 'spec_helper'

describe Equatable, '#eql?' do
  let(:name) { 'Value' }
  let(:value) { 11 }

  let(:klass) {
    ::Class.new do
      include Equatable

      attr_reader :value

      def initialize(value)
        @value = value
      end
    end
  }

  let(:object) { klass.new(value) }

  subject { object.eql?(other) }

  context 'with the same object' do
    let(:other) { object }

    it { is_expected.to eql(true) }

    it 'is symmetric' do
      is_expected.to eql(other.eql?(object))
    end
  end

  context 'with an equivalent object' do
    let(:other) { object.dup }

    it { is_expected.to eql(true) }

    it 'is symmetric' do
      is_expected.to eql(other.eql?(object))
    end
  end

  context 'with an equivalent object of a subclass' do
    let(:other) { ::Class.new(klass).new(value) }

    it { is_expected.to eql(false) }

    it 'is symmetric' do
      is_expected.to eql(other.eql?(object))
    end
  end
end
