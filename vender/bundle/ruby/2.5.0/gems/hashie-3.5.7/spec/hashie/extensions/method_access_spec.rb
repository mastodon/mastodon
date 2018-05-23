require 'spec_helper'

describe Hashie::Extensions::MethodReader do
  class ReaderHash < Hash
    include Hashie::Extensions::MethodReader

    def initialize(hash = {})
      update(hash)
    end
  end

  subject { ReaderHash }

  it 'reads string keys from the method' do
    expect(subject.new('awesome' => 'sauce').awesome).to eq 'sauce'
  end

  it 'reads symbol keys from the method' do
    expect(subject.new(awesome: 'sauce').awesome).to eq 'sauce'
  end

  it 'reads nil and false values out properly' do
    h = subject.new(nil: nil, false: false)
    expect(h.nil).to eq nil
    expect(h.false).to eq false
  end

  it 'raises a NoMethodError for undefined keys' do
    expect { subject.new.awesome }.to raise_error(NoMethodError)
  end

  it 'returns false for undefined keys if key with question has been called ' do
    expect(subject.new.awesome?).to eq false
  end

  it 'returns true for defined keys if key with question has been called' do
    expect(subject.new(awesome: 'sauce').awesome?).to eq true
  end

  describe '#respond_to?' do
    it 'is true for string keys' do
      expect(subject.new('awesome' => 'sauce')).to be_respond_to(:awesome)
    end

    it 'is true for symbol keys' do
      expect(subject.new(awesome: 'sauce')).to be_respond_to(:awesome)
    end

    it 'is false for non-keys' do
      expect(subject.new).not_to be_respond_to(:awesome)
    end
  end
end

describe Hashie::Extensions::MethodWriter do
  class WriterHash < Hash
    include Hashie::Extensions::MethodWriter
  end

  subject { WriterHash.new }

  it 'writes from a method call' do
    subject.awesome = 'sauce'
    expect(subject['awesome']).to eq 'sauce'
  end

  it 'converts the key using the #convert_key method' do
    allow(subject).to receive(:convert_key).and_return(:awesome)
    subject.awesome = 'sauce'
    expect(subject[:awesome]).to eq 'sauce'
  end

  it 'raises NoMethodError on non equals-ending methods' do
    expect { subject.awesome }.to raise_error(NoMethodError)
  end

  it '#respond_to? correctly' do
    expect(subject).to be_respond_to(:abc=)
    expect(subject).not_to be_respond_to(:abc)
  end
end

describe Hashie::Extensions::MethodQuery do
  class QueryHash < Hash
    include Hashie::Extensions::MethodQuery

    def initialize(hash = {})
      update(hash)
    end
  end

  subject { QueryHash }

  it 'is true for non-nil string key values' do
    expect(subject.new('abc' => 123).abc?).to eq true
  end

  it 'is true for non-nil symbol key values' do
    expect(subject.new(abc: 123).abc?).to eq true
  end

  it 'is false for false key values' do
    expect(subject.new(abc: false).abc?).to eq false
  end

  it 'is false for nil key values' do
    expect(subject.new(abc: nil).abc?).to eq false
  end

  it 'raises a NoMethodError for non-set keys' do
    expect { subject.new.abc? }.to raise_error(NoMethodError)
  end

  it '#respond_to? for existing string keys' do
    expect(subject.new('abc' => 'def')).to be_respond_to('abc?')
  end

  it '#respond_to? for existing symbol keys' do
    expect(subject.new(abc: 'def')).to be_respond_to(:abc?)
  end

  it 'does not #respond_to? for non-existent keys' do
    expect(subject.new).not_to be_respond_to('abc?')
  end
end

describe Hashie::Extensions::MethodAccess do
  it 'includes all of the other method mixins' do
    klass = Class.new(Hash)
    klass.send :include, Hashie::Extensions::MethodAccess
    expect((klass.ancestors & [Hashie::Extensions::MethodReader, Hashie::Extensions::MethodWriter, Hashie::Extensions::MethodQuery]).size).to eq 3
  end
end

describe Hashie::Extensions::MethodOverridingWriter do
  class OverridingHash < Hash
    include Hashie::Extensions::MethodOverridingWriter
  end

  subject { OverridingHash.new }

  it 'writes from a method call' do
    subject.awesome = 'sauce'
    expect(subject['awesome']).to eq 'sauce'
  end

  it 'convertes the key using the #convert_key method' do
    allow(subject).to receive(:convert_key).and_return(:awesome)
    subject.awesome = 'sauce'
    expect(subject[:awesome]).to eq 'sauce'
  end

  it 'raises NoMethodError on non equals-ending methods' do
    expect { subject.awesome }.to raise_error(NoMethodError)
  end

  it '#respond_to_missing? correctly' do
    expect(subject).to respond_to(:abc=)
    expect(subject).not_to respond_to(:abc)
    expect(subject.method(:abc=)).not_to be_nil
  end

  context 'when writing a Hash method' do
    before { subject.zip = 'a-dee-doo-dah' }

    it 'overrides the original method' do
      expect(subject.zip).to eq 'a-dee-doo-dah'
    end

    it 'aliases the method with two leading underscores' do
      expect(subject.__zip).to eq [[%w(zip a-dee-doo-dah)]]
    end

    it 'does not re-alias when overriding an already overridden method' do
      subject.zip = 'test'
      expect(subject.zip).to eq 'test'
      expect(subject.__zip).to eq [[%w(zip test)]]
    end
  end
end

describe Hashie::Extensions::MethodAccessWithOverride do
  it 'includes all of the other method mixins' do
    klass = Class.new(Hash)
    klass.send :include, Hashie::Extensions::MethodAccessWithOverride
    expect((klass.ancestors & [Hashie::Extensions::MethodReader, Hashie::Extensions::MethodOverridingWriter, Hashie::Extensions::MethodQuery]).size).to eq 3
  end
end
