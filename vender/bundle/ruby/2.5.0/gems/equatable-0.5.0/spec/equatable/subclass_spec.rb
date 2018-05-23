# encoding: utf-8

require 'spec_helper'

describe Equatable, 'subclass' do
  let(:name) { 'Value' }

  context 'when subclass' do
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
    let(:subclass) { ::Class.new(klass) }

    subject { subclass.new(value) }

    before { allow(klass).to receive(:name).and_return(name) }

    it { expect(subclass.superclass).to eq(klass) }

    it { is_expected.to respond_to(:value) }

    describe '#inspect' do
      it { expect(subject.inspect).to eql('#<Value value=11>') }
    end

    describe '#eql?' do
      context 'when objects are similar' do
        let(:other) { subject.dup }

        it { expect(subject.eql?(other)).to eql(true) }
      end

      context 'when objects are different' do
        let(:other) { double('other') }

        it { expect(subject.eql?(other)).to eql(false) }
      end
    end

    describe '#==' do
      context 'when objects are similar' do
        let(:other) { subject.dup }

        it { expect(subject == other).to eql(true) }
      end

      context 'when objects are different' do
        let(:other) { double('other') }

        it { expect(subject == other).to eql(false) }
      end
    end
  end
end
