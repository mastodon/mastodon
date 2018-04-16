# This set of tests verifies that Hashie::Extensions::IndifferentAccess works with
# ActiveSupport HashWithIndifferentAccess hashes. See #164 and #166 for details.

require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'spec_helper'

describe Hashie::Extensions::IndifferentAccess do
  class IndifferentHashWithMergeInitializer < Hash
    include Hashie::Extensions::MergeInitializer
    include Hashie::Extensions::IndifferentAccess

    class << self
      alias_method :build, :new
    end
  end

  class IndifferentHashWithArrayInitializer < Hash
    include Hashie::Extensions::IndifferentAccess

    class << self
      alias_method :build, :[]
    end
  end

  class IndifferentHashWithTryConvertInitializer < Hash
    include Hashie::Extensions::IndifferentAccess

    class << self
      alias_method :build, :try_convert
    end
  end

  class CoercableHash < Hash
    include Hashie::Extensions::Coercion
    include Hashie::Extensions::MergeInitializer
  end

  class MashWithIndifferentAccess < Hashie::Mash
    include Hashie::Extensions::IndifferentAccess
  end

  shared_examples_for 'hash with indifferent access' do
    it 'is able to access via string or symbol' do
      indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(abc: 123)
      h = subject.build(indifferent_hash)
      expect(h[:abc]).to eq 123
      expect(h['abc']).to eq 123
    end

    describe '#values_at' do
      it 'indifferently finds values' do
        indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(
          :foo => 'bar', 'baz' => 'qux'
        )
        h = subject.build(indifferent_hash)
        expect(h.values_at('foo', :baz)).to eq %w(bar qux)
      end
    end

    describe '#fetch' do
      it 'works like normal fetch, but indifferent' do
        indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(foo: 'bar')
        h = subject.build(indifferent_hash)
        expect(h.fetch(:foo)).to eq h.fetch('foo')
        expect(h.fetch(:foo)).to eq 'bar'
      end
    end

    describe '#delete' do
      it 'deletes indifferently' do
        indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(
          :foo => 'bar',
          'baz' => 'qux'
        )
        h = subject.build(indifferent_hash)
        h.delete('foo')
        h.delete(:baz)
        expect(h).to be_empty
      end
    end

    describe '#key?' do
      let(:h) do
        indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(foo: 'bar')
        subject.build(indifferent_hash)
      end

      it 'finds it indifferently' do
        expect(h).to be_key(:foo)
        expect(h).to be_key('foo')
      end

      %w(include? member? has_key?).each do |key_alias|
        it "is aliased as #{key_alias}" do
          expect(h.send(key_alias.to_sym, :foo)).to be(true)
          expect(h.send(key_alias.to_sym, 'foo')).to be(true)
        end
      end
    end

    describe '#update' do
      let(:h) do
        indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(foo: 'bar')
        subject.build(indifferent_hash)
      end

      it 'allows keys to be indifferent still' do
        h.update(baz: 'qux')
        expect(h['foo']).to eq 'bar'
        expect(h['baz']).to eq 'qux'
      end

      it 'recursively injects indifference into sub-hashes' do
        h.update(baz: { qux: 'abc' })
        expect(h['baz']['qux']).to eq 'abc'
      end

      it 'does not change the ancestors of the injected object class' do
        h.update(baz: { qux: 'abc' })
        expect({}).not_to be_respond_to(:indifferent_access?)
      end
    end

    describe '#replace' do
      let(:h) do
        indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(foo: 'bar')
        subject.build(indifferent_hash).replace(bar: 'baz', hi: 'bye')
      end

      it 'returns self' do
        expect(h).to be_a(subject)
      end

      it 'removes old keys' do
        [:foo, 'foo'].each do |k|
          expect(h[k]).to be_nil
          expect(h.key?(k)).to be_falsy
        end
      end

      it 'creates new keys with indifferent access' do
        [:bar, 'bar', :hi, 'hi'].each { |k| expect(h.key?(k)).to be_truthy }
        expect(h[:bar]).to eq 'baz'
        expect(h['bar']).to eq 'baz'
        expect(h[:hi]).to eq 'bye'
        expect(h['hi']).to eq 'bye'
      end
    end

    describe '#try_convert' do
      describe 'with conversion' do
        let(:h) do
          indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(foo: 'bar')
          subject.try_convert(indifferent_hash)
        end

        it 'is a subject' do
          expect(h).to be_a(subject)
        end
      end

      describe 'without conversion' do
        let(:h) { subject.try_convert('{ :foo => bar }') }

        it 'is nil' do
          expect(h).to be_nil
        end
      end
    end
  end

  describe 'with merge initializer' do
    subject { IndifferentHashWithMergeInitializer }
    it_should_behave_like 'hash with indifferent access'
  end

  describe 'with array initializer' do
    subject { IndifferentHashWithArrayInitializer }
    it_should_behave_like 'hash with indifferent access'
  end

  describe 'with try convert initializer' do
    subject { IndifferentHashWithTryConvertInitializer }
    it_should_behave_like 'hash with indifferent access'
  end

  describe 'with coercion' do
    subject { CoercableHash }

    let(:instance) { subject.new }

    it 'supports coercion for ActiveSupport::HashWithIndifferentAccess' do
      subject.coerce_key :foo, ActiveSupport::HashWithIndifferentAccess.new(Coercable => Coercable)
      instance[:foo] = { 'bar_key' => 'bar_value', 'bar2_key' => 'bar2_value' }
      expect(instance[:foo].keys).to all(be_coerced)
      expect(instance[:foo].values).to all(be_coerced)
      expect(instance[:foo]).to be_a(ActiveSupport::HashWithIndifferentAccess)
    end
  end

  describe 'Mash with indifferent access' do
    it 'is able to be created for a deep nested HashWithIndifferentAccess' do
      indifferent_hash = ActiveSupport::HashWithIndifferentAccess.new(abc: { def: 123 })
      MashWithIndifferentAccess.new(indifferent_hash)
    end
  end
end
