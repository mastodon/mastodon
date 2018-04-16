# encoding: utf-8

require 'spec_helper'

describe Equatable, '#include' do
  let(:name)   { 'Value' }
  let(:object) { described_class }

  context 'without attributes' do
    let(:klass) { ::Class.new }

    subject { klass.new }

    before {
      allow(klass).to receive(:name).and_return(name)
      klass.send(:include, object)
    }

    it { is_expected.to respond_to(:compare?) }

    it { is_expected.to be_instance_of(klass) }

    it 'has no attribute names' do
      expect(klass.comparison_attrs).to eq([])
    end

    describe '#inspect' do
      it { expect(subject.inspect).to eql('#<Value>') }
    end

    describe '#hash' do
      it { expect(subject.hash).to eql([klass].hash) }
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

    context 'equivalence relation' do
      let(:other)   { subject.dup }
      let(:another) { other.dup }

      it 'is not equal to nil reference' do
        expect(subject.eql?(nil)).to eql(false)
      end

      it 'is reflexive' do
        expect(subject.eql?(subject)).to eql(true)
      end

      it 'is symmetric' do
        expect(subject.eql?(other)).to eql( other.eql?(subject) )
      end

      it 'is transitive' do
        expect(subject.eql?(other) && other.eql?(another)).to eql(subject.eql?(another))
      end
    end
  end

  context 'with attributes' do
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

    before { allow(klass).to receive(:name).and_return(name) }

    subject { klass.new(value) }

    it 'dynamically defines #hash method' do
      expect(klass.method_defined?(:hash)).to eql(true)
    end

    it 'dynamically defines #inspect method' do
      expect(klass.method_defined?(:inspect)).to eql(true)
    end

    it { is_expected.to respond_to(:compare?) }

    it { is_expected.to respond_to(:eql?) }

    it 'has comparison attribute names' do
      expect(klass.comparison_attrs).to eq([:value])
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

    describe '#inspect' do
      it { expect(subject.inspect).to eql('#<Value value=11>') }
    end

    describe '#hash' do
      it { expect(subject.hash).to eql( ([klass] + [value]).hash) }
    end

    context 'equivalence relation' do
      let(:other)   { subject.dup }
      let(:another) { other.dup }

      it 'is not equal to nil reference' do
        expect(subject.eql?(nil)).to eql(false)
      end

      it 'is reflexive' do
        expect(subject.eql?(subject)).to eql(true)
      end

      it 'is symmetric' do
        expect(subject.eql?(other)).to eql( other.eql?(subject) )
      end

      it 'is transitive' do
        expect(subject.eql?(other) && other.eql?(another)).to eql(subject.eql?(another))
      end
    end
  end
end
