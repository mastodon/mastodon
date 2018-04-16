describe Wisper::ValueObjects::Events do
  context 'nil' do
    subject { described_class.new nil }

    describe '#include?' do
      it 'returns true' do
        expect(subject.include? 'foo').to be_truthy
        expect(subject.include? :bar).to be_truthy
      end
    end
  end

  context '"foo"' do
    let(:foo) { Class.new(String).new 'foo' }
    subject   { described_class.new foo }

    describe '#include?' do
      it 'returns true for "foo"' do
        expect(subject.include? 'foo').to be_truthy
      end

      it 'returns true for :foo' do
        expect(subject.include? :foo).to be_truthy
      end

      it 'returns false otherwise' do
        expect(subject.include? 'bar').to be_falsey
        expect(subject.include? :bar).to be_falsey
      end
    end
  end

  context ':foo' do
    subject { described_class.new :foo }

    describe '#include?' do
      it 'returns true for "foo"' do
        expect(subject.include? 'foo').to be_truthy
      end

      it 'returns true for :foo' do
        expect(subject.include? :foo).to be_truthy
      end

      it 'returns false otherwise' do
        expect(subject.include? 'bar').to be_falsey
        expect(subject.include? :bar).to be_falsey
      end
    end
  end

  context '[:foo, "bar"]' do
    subject { described_class.new [:foo, 'bar'] }

    describe '#include?' do
      it 'returns true for "foo"' do
        expect(subject.include? 'foo').to be_truthy
      end

      it 'returns true for :foo' do
        expect(subject.include? :foo).to be_truthy
      end

      it 'returns true for "bar"' do
        expect(subject.include? 'bar').to be_truthy
      end

      it 'returns true for :bar' do
        expect(subject.include? :bar).to be_truthy
      end

      it 'returns false otherwise' do
        expect(subject.include? 'baz').to be_falsey
        expect(subject.include? :baz).to be_falsey
      end
    end
  end

  context 'by /foo/' do
    subject { described_class.new(/foo/) }

    describe '#include?' do
      it 'returns true for "foo"' do
        expect(subject.include? 'foo').to be_truthy
      end

      it 'returns true for :foo' do
        expect(subject.include? :foo).to be_truthy
      end

      it 'returns false otherwise' do
        expect(subject.include? 'bar').to be_falsey
        expect(subject.include? :bar).to be_falsey
      end
    end
  end

  context 'another class' do
    subject { described_class.new Object.new }

    describe '#include?' do
      it 'raises ArgumentError' do
        expect { subject.include? 'foo' }.to raise_error(ArgumentError)
      end
    end
  end
end
