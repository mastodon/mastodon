require 'spec_helper'

describe Hashie::Mash do
  subject { Hashie::Mash.new }

  include_context 'with a logger'

  it 'inherits from Hash' do
    expect(subject.is_a?(Hash)).to be_truthy
  end

  it 'sets hash values through method= calls' do
    subject.test = 'abc'
    expect(subject['test']).to eq 'abc'
  end

  it 'retrieves set values through method calls' do
    subject['test'] = 'abc'
    expect(subject.test).to eq 'abc'
  end

  it 'retrieves set values through blocks' do
    subject['test'] = 'abc'
    value = nil
    subject.[]('test') { |v| value = v }
    expect(value).to eq 'abc'
  end

  it 'retrieves set values through blocks with method calls' do
    subject['test'] = 'abc'
    value = nil
    subject.test { |v| value = v }
    expect(value).to eq 'abc'
  end

  it 'tests for already set values when passed a ? method' do
    expect(subject.test?).to be_falsy
    subject.test = 'abc'
    expect(subject.test?).to be_truthy
  end

  it 'returns false on a ? method if a value has been set to nil or false' do
    subject.test = nil
    expect(subject).not_to be_test
    subject.test = false
    expect(subject).not_to be_test
  end

  it 'makes all [] and []= into strings for consistency' do
    subject['abc'] = 123
    expect(subject.key?('abc')).to be_truthy
    expect(subject['abc']).to eq 123
  end

  it 'has a to_s that is identical to its inspect' do
    subject.abc = 123
    expect(subject.to_s).to eq subject.inspect
  end

  it 'returns nil instead of raising an error for attribute-esque method calls' do
    expect(subject.abc).to be_nil
  end

  it 'returns the default value if set like Hash' do
    subject.default = 123
    expect(subject.abc).to eq 123
  end

  it 'gracefully handles being accessed with arguments' do
    expect(subject.abc('foobar')).to eq nil
    subject.abc = 123
    expect(subject.abc('foobar')).to eq 123
  end

  # Added due to downstream gems assuming indifferent access to be true for Mash
  # When this is not, bump major version so that downstream gems can target
  # correct version and fix accordingly.
  # See https://github.com/intridea/hashie/pull/197
  it 'maintains indifferent access when nested' do
    subject[:a] = { b: 'c' }
    expect(subject[:a][:b]).to eq 'c'
    expect(subject[:a]['b']).to eq 'c'
  end

  it 'returns a Hashie::Mash when passed a bang method to a non-existenct key' do
    expect(subject.abc!.is_a?(Hashie::Mash)).to be_truthy
  end

  it 'returns the existing value when passed a bang method for an existing key' do
    subject.name = 'Bob'
    expect(subject.name!).to eq 'Bob'
  end

  it 'returns a Hashie::Mash when passed an under bang method to a non-existenct key' do
    expect(subject.abc_.is_a?(Hashie::Mash)).to be_truthy
  end

  it 'returns the existing value when passed an under bang method for an existing key' do
    subject.name = 'Bob'
    expect(subject.name_).to eq 'Bob'
  end

  it '#initializing_reader returns a Hashie::Mash when passed a non-existent key' do
    expect(subject.initializing_reader(:abc).is_a?(Hashie::Mash)).to be_truthy
  end

  it 'allows for multi-level assignment through bang methods' do
    subject.author!.name = 'Michael Bleigh'
    expect(subject.author).to eq Hashie::Mash.new(name: 'Michael Bleigh')
    subject.author!.website!.url = 'http://www.mbleigh.com/'
    expect(subject.author.website).to eq Hashie::Mash.new(url: 'http://www.mbleigh.com/')
  end

  it 'allows for multi-level under bang testing' do
    expect(subject.author_.website_.url).to be_nil
    expect(subject.author_.website_.url?).to eq false
    expect(subject.author).to be_nil
  end

  it 'does not call super if id is not a key' do
    expect(subject.id).to eq nil
  end

  it 'returns the value if id is a key' do
    subject.id = 'Steve'
    expect(subject.id).to eq 'Steve'
  end

  it 'does not call super if type is not a key' do
    expect(subject.type).to eq nil
  end

  it 'returns the value if type is a key' do
    subject.type = 'Steve'
    expect(subject.type).to eq 'Steve'
  end

  include_context 'with a logger' do
    it 'logs a warning when overriding built-in methods' do
      Hashie::Mash.new('trust' => { 'two' => 2 })

      expect(logger_output).to match('Hashie::Mash#trust')
    end

    it 'can set keys more than once and does not warn when doing so' do
      mash = Hashie::Mash.new
      mash[:test_key] = 'Test value'

      expect { mash[:test_key] = 'A new value' }.not_to raise_error
      expect(logger_output).to be_blank
    end

    it 'does not write to the logger when warnings are disabled' do
      mash_class = Class.new(Hashie::Mash) do
        disable_warnings
      end

      mash_class.new('trust' => { 'two' => 2 })

      expect(logger_output).to be_blank
    end

    it 'cannot disable logging on the base Mash' do
      expect { Hashie::Mash.disable_warnings }.to raise_error(Hashie::Mash::CannotDisableMashWarnings)
    end

    it 'carries over the disable for warnings on grandchild classes' do
      child_class = Class.new(Hashie::Mash) do
        disable_warnings
      end
      grandchild_class = Class.new(child_class)

      grandchild_class.new('trust' => { 'two' => 2 })

      expect(logger_output).to be_blank
    end
  end

  context 'updating' do
    subject do
      described_class.new(
        first_name: 'Michael',
        last_name: 'Bleigh',
        details: {
          email: 'michael@asf.com',
          address: 'Nowhere road'
        })
    end

    describe '#deep_update' do
      it 'recursively Hashie::Mash Hashie::Mashes and hashes together' do
        subject.deep_update(details: { email: 'michael@intridea.com', city: 'Imagineton' })
        expect(subject.first_name).to eq 'Michael'
        expect(subject.details.email).to eq 'michael@intridea.com'
        expect(subject.details.address).to eq 'Nowhere road'
        expect(subject.details.city).to eq 'Imagineton'
      end

      it 'converts values only once' do
        class ConvertedMash < Hashie::Mash
        end

        rhs = ConvertedMash.new(email: 'foo@bar.com')
        expect(subject).to receive(:convert_value).exactly(1).times
        subject.deep_update(rhs)
      end

      it 'makes #update deep by default' do
        expect(subject.update(details: { address: 'Fake street' })).to eql(subject)
        expect(subject.details.address).to eq 'Fake street'
        expect(subject.details.email).to eq 'michael@asf.com'
      end

      it 'clones before a #deep_merge' do
        duped = subject.deep_merge(details: { address: 'Fake street' })
        expect(duped).not_to eql(subject)
        expect(duped.details.address).to eq 'Fake street'
        expect(subject.details.address).to eq 'Nowhere road'
        expect(duped.details.email).to eq 'michael@asf.com'
      end

      it 'default #merge is deep' do
        duped = subject.merge(details: { email: 'michael@intridea.com' })
        expect(duped).not_to eql(subject)
        expect(duped.details.email).to eq 'michael@intridea.com'
        expect(duped.details.address).to eq 'Nowhere road'
      end

      # http://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-update
      it 'accepts a block' do
        duped = subject.merge(details: { address: 'Pasadena CA' }) { |_, oldv, newv| [oldv, newv].join(', ') }
        expect(duped.details.address).to eq 'Nowhere road, Pasadena CA'
      end

      it 'copies values for non-duplicate keys when a block is supplied' do
        duped = subject.merge(details: { address: 'Pasadena CA', state: 'West Thoughtleby' }) { |_, oldv, _| oldv }
        expect(duped.details.address).to eq 'Nowhere road'
        expect(duped.details.state).to eq 'West Thoughtleby'
      end
    end

    describe 'shallow update' do
      it 'shallowly Hashie::Mash Hashie::Mashes and hashes together' do
        expect(subject.shallow_update(details: {  email: 'michael@intridea.com',
                                                  city: 'Imagineton' })).to eql(subject)

        expect(subject.first_name).to eq 'Michael'
        expect(subject.details.email).to eq 'michael@intridea.com'
        expect(subject.details.address).to be_nil
        expect(subject.details.city).to eq 'Imagineton'
      end

      it 'clones before a #regular_merge' do
        duped = subject.shallow_merge(details: { address: 'Fake street' })
        expect(duped).not_to eql(subject)
      end

      it 'default #merge is shallow' do
        duped = subject.shallow_merge(details: { address: 'Fake street' })
        expect(duped.details.address).to eq 'Fake street'
        expect(subject.details.address).to eq 'Nowhere road'
        expect(duped.details.email).to be_nil
      end
    end

    describe '#replace' do
      before do
        subject.replace(
          middle_name: 'Cain',
          details: { city: 'Imagination' }
        )
      end

      it 'returns self' do
        expect(subject.replace(foo: 'bar').to_hash).to eq('foo' => 'bar')
      end

      it 'sets all specified keys to their corresponding values' do
        expect(subject.middle_name?).to be_truthy
        expect(subject.details?).to be_truthy
        expect(subject.middle_name).to eq 'Cain'
        expect(subject.details.city?).to be_truthy
        expect(subject.details.city).to eq 'Imagination'
      end

      it 'leaves only specified keys' do
        expect(subject.keys.sort).to eq %w(details middle_name)
        expect(subject.first_name?).to be_falsy
        expect(subject).not_to respond_to(:first_name)
        expect(subject.last_name?).to be_falsy
        expect(subject).not_to respond_to(:last_name)
      end
    end

    describe 'delete' do
      it 'deletes with String key' do
        subject.delete('details')
        expect(subject.details).to be_nil
        expect(subject).not_to be_respond_to :details
      end

      it 'deletes with Symbol key' do
        subject.delete(:details)
        expect(subject.details).to be_nil
        expect(subject).not_to be_respond_to :details
      end
    end
  end

  it 'converts hash assignments into Hashie::Mashes' do
    subject.details = { email: 'randy@asf.com', address: { state: 'TX' } }
    expect(subject.details.email).to eq 'randy@asf.com'
    expect(subject.details.address.state).to eq 'TX'
  end

  it 'does not convert the type of Hashie::Mashes childs to Hashie::Mash' do
    class MyMash < Hashie::Mash
    end

    record = MyMash.new
    record.son = MyMash.new
    expect(record.son.class).to eq MyMash
  end

  it 'does not change the class of Mashes when converted' do
    class SubMash < Hashie::Mash
    end

    record = Hashie::Mash.new
    son = SubMash.new
    record['submash'] = son
    expect(record['submash']).to be_kind_of(SubMash)
  end

  it 'respects the class when passed a bang method for a non-existent key' do
    record = Hashie::Mash.new
    expect(record.non_existent!).to be_kind_of(Hashie::Mash)

    class SubMash < Hashie::Mash
    end

    son = SubMash.new
    expect(son.non_existent!).to be_kind_of(SubMash)
  end

  it 'respects the class when passed an under bang method for a non-existent key' do
    record = Hashie::Mash.new
    expect(record.non_existent_).to be_kind_of(Hashie::Mash)

    class SubMash < Hashie::Mash
    end

    son = SubMash.new
    expect(son.non_existent_).to be_kind_of(SubMash)
  end

  it 'respects the class when converting the value' do
    record = Hashie::Mash.new
    record.details = Hashie::Mash.new(email: 'randy@asf.com')
    expect(record.details).to be_kind_of(Hashie::Mash)
  end

  it 'respects another subclass when converting the value' do
    record = Hashie::Mash.new

    class SubMash < Hashie::Mash
    end

    son = SubMash.new(email: 'foo@bar.com')
    record.details = son
    expect(record.details).to be_kind_of(SubMash)
  end

  describe '#respond_to?' do
    subject do
      Hashie::Mash.new(abc: 'def')
    end

    it 'responds to a normal method' do
      expect(subject).to be_respond_to(:key?)
    end

    it 'responds to a set key' do
      expect(subject).to be_respond_to(:abc)
      expect(subject.method(:abc)).to_not be_nil
    end

    it 'responds to a set key with a suffix' do
      %w(= ? ! _).each do |suffix|
        expect(subject).to be_respond_to(:"abc#{suffix}")
      end
    end

    it 'is able to access the suffixed key as a method' do
      %w(= ? ! _).each do |suffix|
        expect(subject.method(:"abc#{suffix}")).to_not be_nil
      end
    end

    it 'responds to an unknown key with a suffix' do
      %w(= ? ! _).each do |suffix|
        expect(subject).to be_respond_to(:"xyz#{suffix}")
      end
    end

    it 'is able to access an unknown suffixed key as a method' do
      # See https://github.com/intridea/hashie/pull/285 for more information
      pending_for(engine: 'ruby', versions: %w(2.2.0 2.2.1 2.2.2))

      %w(= ? ! _).each do |suffix|
        expect(subject.method(:"xyz#{suffix}")).to_not be_nil
      end
    end

    it 'does not respond to an unknown key without a suffix' do
      expect(subject).not_to be_respond_to(:xyz)
      expect { subject.method(:xyz) }.to raise_error(NameError)
    end
  end

  context '#initialize' do
    it 'converts an existing hash to a Hashie::Mash' do
      converted = Hashie::Mash.new(abc: 123, name: 'Bob')
      expect(converted.abc).to eq 123
      expect(converted.name).to eq 'Bob'
    end

    it 'converts hashes recursively into Hashie::Mashes' do
      converted = Hashie::Mash.new(a: { b: 1, c: { d: 23 } })
      expect(converted.a.is_a?(Hashie::Mash)).to be_truthy
      expect(converted.a.b).to eq 1
      expect(converted.a.c.d).to eq 23
    end

    it 'converts hashes in arrays into Hashie::Mashes' do
      converted = Hashie::Mash.new(a: [{ b: 12 }, 23])
      expect(converted.a.first.b).to eq 12
      expect(converted.a.last).to eq 23
    end

    it 'converts an existing Hashie::Mash into a Hashie::Mash' do
      initial = Hashie::Mash.new(name: 'randy', address: { state: 'TX' })
      copy = Hashie::Mash.new(initial)
      expect(initial.name).to eq copy.name
      expect(initial.__id__).not_to eq copy.__id__
      expect(copy.address.state).to eq 'TX'
      copy.address.state = 'MI'
      expect(initial.address.state).to eq 'TX'
      expect(copy.address.__id__).not_to eq initial.address.__id__
    end

    it 'accepts a default block' do
      initial = Hashie::Mash.new { |h, i| h[i] = [] }
      expect(initial.default_proc).not_to be_nil
      expect(initial.default).to be_nil
      expect(initial.test).to eq []
      expect(initial.test?).to be_truthy
    end

    it 'allows assignment of an empty array in a default block' do
      initial = Hashie::Mash.new { |h, k| h[k] = [] }
      initial.hello << 100
      expect(initial.hello).to eq [100]
      initial['hi'] << 100
      expect(initial['hi']).to eq [100]
    end

    it 'allows assignment of a non-empty array in a default block' do
      initial = Hashie::Mash.new { |h, k| h[k] = [100] }
      initial.hello << 200
      expect(initial.hello).to eq [100, 200]
      initial['hi'] << 200
      expect(initial['hi']).to eq [100, 200]
    end

    it 'allows assignment of an empty hash in a default block' do
      initial = Hashie::Mash.new { |h, k| h[k] = {} }
      initial.hello[:a] = 100
      expect(initial.hello).to eq Hashie::Mash.new(a: 100)
      initial[:hi][:a] = 100
      expect(initial[:hi]).to eq Hashie::Mash.new(a: 100)
    end

    it 'allows assignment of a non-empty hash in a default block' do
      initial = Hashie::Mash.new { |h, k| h[k] = { a: 100 } }
      initial.hello[:b] = 200
      expect(initial.hello).to eq Hashie::Mash.new(a: 100, b: 200)
      initial[:hi][:b] = 200
      expect(initial[:hi]).to eq Hashie::Mash.new(a: 100, b: 200)
    end

    it 'converts Hashie::Mashes within Arrays back to Hashes' do
      initial_hash = { 'a' => [{ 'b' => 12, 'c' => ['d' => 50, 'e' => 51] }, 23] }
      converted = Hashie::Mash.new(initial_hash)
      expect(converted.to_hash['a'].first.is_a?(Hashie::Mash)).to be_falsy
      expect(converted.to_hash['a'].first.is_a?(Hash)).to be_truthy
      expect(converted.to_hash['a'].first['c'].first.is_a?(Hashie::Mash)).to be_falsy
    end
  end

  describe '#fetch' do
    let(:hash) { { one: 1, other: false } }
    let(:mash) { Hashie::Mash.new(hash) }

    context 'when key exists' do
      it 'returns the value' do
        expect(mash.fetch(:one)).to eql(1)
      end

      it 'returns the value even if the value is falsy' do
        expect(mash.fetch(:other)).to eql(false)
      end

      context 'when key has other than original but acceptable type' do
        it 'returns the value' do
          expect(mash.fetch('one')).to eql(1)
        end
      end
    end

    context 'when key does not exist' do
      it 'raises KeyError' do
        error = RUBY_VERSION =~ /1.8/ ? IndexError : KeyError
        expect { mash.fetch(:two) }.to raise_error(error)
      end

      context 'with default value given' do
        it 'returns default value' do
          expect(mash.fetch(:two, 8)).to eql(8)
        end

        it 'returns default value even if it is falsy' do
          expect(mash.fetch(:two, false)).to eql(false)
        end
      end

      context 'with block given' do
        it 'returns default value' do
          expect(mash.fetch(:two) do
            'block default value'
          end).to eql('block default value')
        end
      end
    end
  end

  describe '#to_hash' do
    let(:hash) { { 'outer' => { 'inner' => 42 }, 'testing' => [1, 2, 3] } }
    let(:mash) { Hashie::Mash.new(hash) }

    it 'returns a standard Hash' do
      expect(mash.to_hash).to be_a(::Hash)
    end

    it 'includes all keys' do
      expect(mash.to_hash.keys).to eql(%w(outer testing))
    end

    it 'converts keys to symbols when symbolize_keys option is true' do
      expect(mash.to_hash(symbolize_keys: true).keys).to include(:outer)
      expect(mash.to_hash(symbolize_keys: true).keys).not_to include('outer')
    end

    it 'leaves keys as strings when symbolize_keys option is false' do
      expect(mash.to_hash(symbolize_keys: false).keys).to include('outer')
      expect(mash.to_hash(symbolize_keys: false).keys).not_to include(:outer)
    end

    it 'symbolizes keys recursively' do
      expect(mash.to_hash(symbolize_keys: true)[:outer].keys).to include(:inner)
      expect(mash.to_hash(symbolize_keys: true)[:outer].keys).not_to include('inner')
    end
  end

  describe '#stringify_keys' do
    it 'turns all keys into strings recursively' do
      hash = Hashie::Mash[:a => 'hey', 123 => { 345 => 'hey' }]
      hash.stringify_keys!
      expect(hash).to eq Hashie::Hash['a' => 'hey', '123' => { '345' => 'hey' }]
    end
  end

  describe '#values_at' do
    let(:hash) { { 'key_one' => 1, :key_two => 2 } }
    let(:mash) { Hashie::Mash.new(hash) }

    context 'when the original type is given' do
      it 'returns the values' do
        expect(mash.values_at('key_one', :key_two)).to eq([1, 2])
      end
    end

    context 'when a different, but acceptable type is given' do
      it 'returns the values' do
        expect(mash.values_at(:key_one, 'key_two')).to eq([1, 2])
      end
    end

    context 'when a key is given that is not in the Mash' do
      it 'returns nil for that value' do
        expect(mash.values_at('key_one', :key_three)).to eq([1, nil])
      end
    end
  end

  describe '.load(filename, options = {})' do
    let(:config) do
      {
        'production' => {
          'foo' => 'production_foo'
        }
      }
    end
    let(:path) { 'database.yml' }
    let(:parser) { double(:parser) }

    subject { described_class.load(path, parser: parser) }

    before do |ex|
      unless ex.metadata == :test_cache
        described_class.instance_variable_set('@_mashes', nil) # clean the cached mashes
      end
    end

    context 'if the file exists' do
      before do
        expect(File).to receive(:file?).with(path).and_return(true)
        expect(parser).to receive(:perform).with(path).and_return(config)
      end

      it { is_expected.to be_a(Hashie::Mash) }

      it 'return a Mash from a file' do
        expect(subject.production).not_to be_nil
        expect(subject.production.keys).to eq config['production'].keys
        expect(subject.production.foo).to eq config['production']['foo']
      end

      it 'freeze the attribtues' do
        expect { subject.production = {} }.to raise_exception(RuntimeError, /can't modify frozen/)
      end
    end

    context 'if the fils does not exists' do
      before do
        expect(File).to receive(:file?).with(path).and_return(false)
      end

      it 'raise an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'if the file is passed as Pathname' do
      require 'pathname'
      let(:path) { Pathname.new('database.yml') }

      before do
        expect(File).to receive(:file?).with(path).and_return(true)
        expect(parser).to receive(:perform).with(path).and_return(config)
      end

      it 'return a Mash from a file' do
        expect(subject.production.foo).to eq config['production']['foo']
      end
    end

    describe 'results are cached' do
      let(:parser) { double(:parser) }

      subject { described_class.load(path, parser: parser) }

      before do
        expect(File).to receive(:file?).with(path).and_return(true)
        expect(File).to receive(:file?).with("#{path}+1").and_return(true)
        expect(parser).to receive(:perform).once.with(path).and_return(config)
        expect(parser).to receive(:perform).once.with("#{path}+1").and_return(config)
      end

      it 'cache the loaded yml file', :test_cache do
        2.times do
          expect(subject).to be_a(described_class)
          expect(described_class.load("#{path}+1", parser: parser)).to be_a(described_class)
        end

        expect(subject.object_id).to eq subject.object_id
      end
    end
  end

  describe '#to_module(mash_method_name)' do
    let(:mash) { described_class.new }
    subject { Class.new.extend mash.to_module }

    it 'defines a settings method on the klass class that extends the module' do
      expect(subject).to respond_to(:settings)
      expect(subject.settings).to eq mash
    end

    context 'when a settings_method_name is set' do
      let(:mash_method_name) { 'config' }

      subject { Class.new.extend mash.to_module(mash_method_name) }

      it 'defines a settings method on the klass class that extends the module' do
        expect(subject).to respond_to(mash_method_name.to_sym)
        expect(subject.send(mash_method_name.to_sym)).to eq mash
      end
    end
  end

  describe '#extractable_options?' do
    require 'active_support'

    subject { described_class.new(name: 'foo') }
    let(:args) { [101, 'bar', subject] }

    it 'can be extracted from an array' do
      expect(args.extract_options!).to eq subject
      expect(args).to eq [101, 'bar']
    end
  end

  describe '#reverse_merge' do
    subject { described_class.new(a: 1, b: 2) }

    it 'unifies strings and symbols' do
      expect(subject.reverse_merge(a: 2).length).to eq 2
      expect(subject.reverse_merge('a' => 2).length).to eq 2
    end

    it 'does not overwrite values' do
      expect(subject.reverse_merge(a: 5).a).to eq subject.a
    end

    context 'when using with subclass' do
      let(:subclass) { Class.new(Hashie::Mash) }
      subject { subclass.new(a: 1) }

      it 'creates an instance of subclass' do
        expect(subject.reverse_merge(a: 5)).to be_kind_of(subclass)
      end
    end
  end

  with_minimum_ruby('2.3.0') do
    describe '#dig' do
      subject { described_class.new(a: { b: 1 }) }
      it 'accepts both string and symbol as key' do
        expect(subject.dig(:a, :b)).to eq(1)
        expect(subject.dig('a', 'b')).to eq(1)
      end

      context 'with numeric key' do
        subject { described_class.new('1' => { b: 1 }) }
        it 'accepts a numeric value as key' do
          expect(subject.dig(1, :b)).to eq(1)
          expect(subject.dig('1', :b)).to eq(1)
        end
      end
    end
  end
end
