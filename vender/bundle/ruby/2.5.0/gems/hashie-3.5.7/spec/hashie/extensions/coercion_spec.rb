require 'spec_helper'

describe Hashie::Extensions::Coercion do
  class NotInitializable
    private_class_method :new
  end

  class Initializable
    attr_reader :coerced, :value

    def initialize(obj, coerced = nil)
      @coerced = coerced
      @value = obj.class.to_s
    end

    def coerced?
      !@coerced.nil?
    end
  end

  class Coercable < Initializable
    def self.coerce(obj)
      new(obj, true)
    end
  end

  before(:each) do
    class ExampleCoercableHash < Hash
      include Hashie::Extensions::Coercion
      include Hashie::Extensions::MergeInitializer
    end
  end

  subject { ExampleCoercableHash }

  let(:instance) { subject.new }

  describe '#coerce_key' do
    context 'nesting' do
      class BaseCoercableHash < Hash
        include Hashie::Extensions::Coercion
        include Hashie::Extensions::MergeInitializer
      end

      class NestedCoercableHash < BaseCoercableHash
        coerce_key :foo, String
        coerce_key :bar, Integer
      end

      class OtherNestedCoercableHash < BaseCoercableHash
        coerce_key :foo, Symbol
      end

      class RootCoercableHash < BaseCoercableHash
        coerce_key :nested, NestedCoercableHash
        coerce_key :other, OtherNestedCoercableHash
        coerce_key :nested_list, Array[NestedCoercableHash]
        coerce_key :nested_hash, Hash[String => NestedCoercableHash]
      end

      def test_nested_object(obj)
        expect(obj).to be_a(NestedCoercableHash)
        expect(obj[:foo]).to be_a(String)
        expect(obj[:bar]).to be_an(Integer)
      end

      subject { RootCoercableHash }
      let(:instance) { subject.new }

      it 'does not add coercions to superclass' do
        instance[:nested] = { foo: 'bar' }
        instance[:other]  = { foo: 'bar' }
        expect(instance[:nested][:foo]).to be_a String
        expect(instance[:other][:foo]).to be_a Symbol
      end

      it 'coerces nested objects' do
        instance[:nested] = { foo: 123, bar: '456' }
        test_nested_object(instance[:nested])
      end

      it 'coerces nested arrays' do
        instance[:nested_list] = [
          { foo: 123, bar: '456' },
          { foo: 234, bar: '567' },
          { foo: 345, bar: '678' }
        ]
        expect(instance[:nested_list]).to be_a Array
        expect(instance[:nested_list].size).to eq(3)
        instance[:nested_list].each do |nested|
          test_nested_object nested
        end
      end

      it 'coerces nested hashes' do
        instance[:nested_hash] = {
          a: { foo: 123, bar: '456' },
          b: { foo: 234, bar: '567' },
          c: { foo: 345, bar: '678' }
        }
        expect(instance[:nested_hash]).to be_a Hash
        expect(instance[:nested_hash].size).to eq(3)
        instance[:nested_hash].each do |key, nested|
          expect(key).to be_a(String)
          test_nested_object nested
        end
      end

      context 'when repetitively including the module' do
        class RepetitiveCoercableHash < NestedCoercableHash
          include Hashie::Extensions::Coercion
          include Hashie::Extensions::MergeInitializer

          coerce_key :nested, NestedCoercableHash
        end

        subject { RepetitiveCoercableHash }
        let(:instance) { subject.new }

        it 'does not raise a stack overflow error' do
          expect do
            instance[:nested] = { foo: 123, bar: '456' }
            test_nested_object(instance[:nested])
          end.not_to raise_error
        end
      end
    end

    it { expect(subject).to be_respond_to(:coerce_key) }

    it 'runs through coerce on a specified key' do
      subject.coerce_key :foo, Coercable

      instance[:foo] = 'bar'
      expect(instance[:foo]).to be_coerced
    end

    it 'skips unnecessary coercions' do
      subject.coerce_key :foo, Coercable

      instance[:foo] = Coercable.new('bar')
      expect(instance[:foo]).to_not be_coerced
    end

    it 'supports an array of keys' do
      subject.coerce_keys :foo, :bar, Coercable

      instance[:foo] = 'bar'
      instance[:bar] = 'bax'
      expect(instance[:foo]).to be_coerced
      expect(instance[:bar]).to be_coerced
    end

    it 'supports coercion for Array' do
      subject.coerce_key :foo, Array[Coercable]

      instance[:foo] = %w('bar', 'bar2')
      expect(instance[:foo]).to all(be_coerced)
      expect(instance[:foo]).to be_a(Array)
    end

    it 'supports coercion for Set' do
      subject.coerce_key :foo, Set[Coercable]

      instance[:foo] = Set.new(%w('bar', 'bar2'))
      expect(instance[:foo]).to all(be_coerced)
      expect(instance[:foo]).to be_a(Set)
    end

    it 'supports coercion for Set of primitive' do
      subject.coerce_key :foo, Set[Initializable]

      instance[:foo] = %w('bar', 'bar2')
      expect(instance[:foo].map(&:value)).to all(eq 'String')
      expect(instance[:foo]).to be_none(&:coerced?)
      expect(instance[:foo]).to be_a(Set)
    end

    it 'supports coercion for Hash' do
      subject.coerce_key :foo, Hash[Coercable => Coercable]

      instance[:foo] = { 'bar_key' => 'bar_value', 'bar2_key' => 'bar2_value' }
      expect(instance[:foo].keys).to all(be_coerced)
      expect(instance[:foo].values).to all(be_coerced)
      expect(instance[:foo]).to be_a(Hash)
    end

    it 'supports coercion for Hash with primitive as value' do
      subject.coerce_key :foo, Hash[Coercable => Initializable]

      instance[:foo] = { 'bar_key' => '1', 'bar2_key' => '2' }
      expect(instance[:foo].values.map(&:value)).to all(eq 'String')
      expect(instance[:foo].keys).to all(be_coerced)
    end

    context 'coercing core types' do
      def test_coercion(literal, target_type, coerce_method)
        subject.coerce_key :foo, target_type
        instance[:foo] = literal
        expect(instance[:foo]).to be_a(target_type)
        expect(instance[:foo]).to eq(literal.send(coerce_method))
      end

      RSpec.shared_examples 'coerces from numeric types' do |target_type, coerce_method|
        it "coerces from String to #{target_type} via #{coerce_method}" do
          test_coercion '2.0', target_type, coerce_method
        end

        it "coerces from Integer to #{target_type} via #{coerce_method}" do
          # Fixnum
          test_coercion 2, target_type, coerce_method
          # Bignum
          test_coercion 12_345_667_890_987_654_321, target_type, coerce_method
        end

        it "coerces from Rational to #{target_type} via #{coerce_method}" do
          test_coercion Rational(2, 3), target_type, coerce_method
        end
      end

      RSpec.shared_examples 'coerces from alphabetical types' do |target_type, coerce_method|
        it "coerces from String to #{target_type} via #{coerce_method}" do
          test_coercion 'abc', target_type, coerce_method
        end

        it "coerces from Symbol to #{target_type} via #{coerce_method}" do
          test_coercion :abc, target_type, coerce_method
        end
      end

      include_examples 'coerces from numeric types', Integer, :to_i
      include_examples 'coerces from numeric types', Float, :to_f
      include_examples 'coerces from numeric types', String, :to_s

      include_examples 'coerces from alphabetical types', String, :to_s
      include_examples 'coerces from alphabetical types', Symbol, :to_sym

      it 'can coerce String to Rational when possible' do
        test_coercion '2/3', Rational, :to_r
      end

      it 'can coerce String to Complex when possible' do
        test_coercion '2/3+3/4i', Complex, :to_c
      end

      it 'coerces collections with core types' do
        subject.coerce_key :foo, Hash[String => String]

        instance[:foo] = {
          abc: 123,
          xyz: 987
        }
        expect(instance[:foo]).to eq(
          'abc' => '123',
          'xyz' => '987'
        )
      end

      it 'can coerce via a proc' do
        subject.coerce_key(:foo, lambda do |v|
          case v
          when String
            return !!(v =~ /^(true|t|yes|y|1)$/i)
          when Numeric
            return !v.to_i.zero?
          else
            return v == true
          end
        end)

        true_values = [true, 'true', 't', 'yes', 'y', '1', 1, -1]
        false_values = [false, 'false', 'f', 'no', 'n', '0', 0]

        true_values.each do |v|
          instance[:foo] = v
          expect(instance[:foo]).to be_a(TrueClass)
        end
        false_values.each do |v|
          instance[:foo] = v
          expect(instance[:foo]).to be_a(FalseClass)
        end
      end

      it 'raises errors for non-coercable types' do
        subject.coerce_key :foo, NotInitializable
        expect { instance[:foo] = 'true' }.to raise_error(Hashie::CoercionError, /NotInitializable is not a coercable type/)
      end

      it 'can coerce false' do
        subject.coerce_key :foo, Coercable

        instance[:foo] = false
        expect(instance[:foo]).to be_coerced
        expect(instance[:foo].value).to eq('FalseClass')
      end

      it 'does not coerce nil' do
        subject.coerce_key :foo, String

        instance[:foo] = nil
        expect(instance[:foo]).to_not eq('')
        expect(instance[:foo]).to be_nil
      end
    end

    it 'calls #new if no coerce method is available' do
      subject.coerce_key :foo, Initializable

      instance[:foo] = 'bar'
      expect(instance[:foo].value).to eq 'String'
      expect(instance[:foo]).not_to be_coerced
    end

    it 'coerces when the merge initializer is used' do
      subject.coerce_key :foo, Coercable
      instance = subject.new(foo: 'bar')

      expect(instance[:foo]).to be_coerced
    end

    context 'when #replace is used' do
      before { subject.coerce_key :foo, :bar, Coercable }

      let(:instance) do
        subject.new(foo: 'bar').replace(foo: 'foz', bar: 'baz', hi: 'bye')
      end

      it 'coerces relevant keys' do
        expect(instance[:foo]).to be_coerced
        expect(instance[:bar]).to be_coerced
        expect(instance[:hi]).not_to respond_to(:coerced?)
      end

      it 'sets correct values' do
        expect(instance[:hi]).to eq 'bye'
      end
    end

    context 'when used with a Mash' do
      class UserMash < Hashie::Mash
      end
      class TweetMash < Hashie::Mash
        include Hashie::Extensions::Coercion
        coerce_key :user, UserMash
      end

      it 'coerces with instance initialization' do
        tweet = TweetMash.new(user: { email: 'foo@bar.com' })
        expect(tweet[:user]).to be_a(UserMash)
      end

      it 'coerces when setting with attribute style' do
        tweet = TweetMash.new
        tweet.user = { email: 'foo@bar.com' }
        expect(tweet[:user]).to be_a(UserMash)
      end

      it 'coerces when setting with string index' do
        tweet = TweetMash.new
        tweet['user'] = { email: 'foo@bar.com' }
        expect(tweet[:user]).to be_a(UserMash)
      end

      it 'coerces when setting with symbol index' do
        tweet = TweetMash.new
        tweet[:user] = { email: 'foo@bar.com' }
        expect(tweet[:user]).to be_a(UserMash)
      end
    end

    context 'when used with a Trash' do
      class UserTrash < Hashie::Trash
        property :email
      end
      class TweetTrash < Hashie::Trash
        include Hashie::Extensions::Coercion

        property :user, from: :user_data
        coerce_key :user, UserTrash
      end

      it 'coerces with instance initialization' do
        tweet = TweetTrash.new(user_data: { email: 'foo@bar.com' })
        expect(tweet[:user]).to be_a(UserTrash)
      end
    end

    context 'when used with IndifferentAccess to coerce a Mash' do
      class MyHash < Hash
        include Hashie::Extensions::Coercion
        include Hashie::Extensions::IndifferentAccess
        include Hashie::Extensions::MergeInitializer
      end

      class UserHash < MyHash
      end

      class TweetHash < MyHash
        coerce_key :user, UserHash
      end

      it 'coerces with instance initialization' do
        tweet = TweetHash.new(user: Hashie::Mash.new(email: 'foo@bar.com'))
        expect(tweet[:user]).to be_a(UserHash)
      end

      it 'coerces when setting with string index' do
        tweet = TweetHash.new
        tweet['user'] = Hashie::Mash.new(email: 'foo@bar.com')
        expect(tweet[:user]).to be_a(UserHash)
      end

      it 'coerces when setting with symbol index' do
        tweet = TweetHash.new
        tweet[:user] = Hashie::Mash.new(email: 'foo@bar.com')
        expect(tweet[:user]).to be_a(UserHash)
      end
    end

    context 'when subclassing' do
      class MyOwnBase < Hash
        include Hashie::Extensions::Coercion
      end

      class MyOwnHash < MyOwnBase
        coerce_key :value, Integer
      end

      class MyOwnSubclass < MyOwnHash
      end

      it 'inherits key coercions' do
        expect(MyOwnHash.key_coercions).to eql(MyOwnSubclass.key_coercions)
      end

      it 'the superclass does not accumulate coerced attributes from subclasses' do
        expect(MyOwnBase.key_coercions).to eq({})
      end
    end

    context 'when using circular coercion' do
      context 'with a proc on one side' do
        class CategoryHash < Hash
          include Hashie::Extensions::Coercion
          include Hashie::Extensions::MergeInitializer

          coerce_key :products, lambda { |value|
            return value.map { |v| ProductHash.new(v) } if value.respond_to?(:map)

            ProductHash.new(v)
          }
        end

        class ProductHash < Hash
          include Hashie::Extensions::Coercion
          include Hashie::Extensions::MergeInitializer

          coerce_key :categories, Array[CategoryHash]
        end

        let(:category) { CategoryHash.new(type: 'rubygem', products: [Hashie::Mash.new(name: 'Hashie')]) }
        let(:product) { ProductHash.new(name: 'Hashie', categories: [Hashie::Mash.new(type: 'rubygem')]) }

        it 'coerces CategoryHash[:products] correctly' do
          expected = [ProductHash]
          actual = category[:products].map(&:class)

          expect(actual).to eq(expected)
        end

        it 'coerces ProductHash[:categories] correctly' do
          expected = [CategoryHash]
          actual = product[:categories].map(&:class)

          expect(actual).to eq(expected)
        end
      end

      context 'without a proc on either side' do
        it 'fails with a NameError since the other class is not defined yet' do
          attempted_code = lambda do
            class AnotherCategoryHash < Hash
              include Hashie::Extensions::Coercion
              include Hashie::Extensions::MergeInitializer

              coerce_key :products, Array[AnotherProductHash]
            end

            class AnotherProductHash < Hash
              include Hashie::Extensions::Coercion
              include Hashie::Extensions::MergeInitializer

              coerce_key :categories, Array[AnotherCategoryHash]
            end
          end

          expect { attempted_code.call }.to raise_error(NameError)
        end
      end
    end
  end

  describe '#coerce_value' do
    context 'with strict: true' do
      it 'coerces any value of the exact right class' do
        subject.coerce_value String, Coercable

        instance[:foo] = 'bar'
        instance[:bar] = 'bax'
        instance[:hi]  = :bye
        expect(instance[:foo]).to be_coerced
        expect(instance[:bar]).to be_coerced
        expect(instance[:hi]).not_to respond_to(:coerced?)
      end

      it 'coerces values from a #replace call' do
        subject.coerce_value String, Coercable

        instance[:foo] = :bar
        instance.replace(foo: 'bar', bar: 'bax')
        expect(instance[:foo]).to be_coerced
        expect(instance[:bar]).to be_coerced
      end

      it 'does not coerce superclasses' do
        klass = Class.new(String)
        subject.coerce_value klass, Coercable

        instance[:foo] = 'bar'
        expect(instance[:foo]).not_to be_kind_of(Coercable)
        instance[:foo] = klass.new
        expect(instance[:foo]).to be_kind_of(Coercable)
      end
    end

    context 'core types' do
      it 'coerces String to Integer when possible' do
        subject.coerce_value String, Integer

        instance[:foo] = '2'
        instance[:bar] = '2.7'
        instance[:hi] = 'hi'
        expect(instance[:foo]).to be_a(Integer)
        expect(instance[:foo]).to eq(2)
        expect(instance[:bar]).to be_a(Integer)
        expect(instance[:bar]).to eq(2)
        expect(instance[:hi]).to be_a(Integer)
        expect(instance[:hi]).to eq(0) # not what I expected...
      end

      it 'coerces non-numeric from String to Integer' do
        # This was surprising, but I guess it's "correct"
        # unless there is a stricter `to_i` alternative
        subject.coerce_value String, Integer
        instance[:hi] = 'hi'
        expect(instance[:hi]).to be_a(Integer)
        expect(instance[:hi]).to eq(0)
      end

      it 'raises a CoercionError when coercion is not possible' do
        type = if Hashie::Extensions::RubyVersion.new(RUBY_VERSION) >= Hashie::Extensions::RubyVersion.new('2.4.0')
                 Integer
               else
                 Fixnum
               end

        subject.coerce_value type, Symbol
        expect { instance[:hi] = 1 }.to raise_error(Hashie::CoercionError, /Cannot coerce property :hi from #{type} to Symbol/)
      end

      it 'coerces Integer to String' do
        subject.coerce_value Integer, String

        {
          fixnum: 2,
          bignum: 12_345_667_890_987_654_321,
          float: 2.7,
          rational: Rational(2, 3),
          complex: Complex(1)
        }.each do |k, v|
          instance[k] = v
          if v.is_a? Integer
            expect(instance[k]).to be_a(String)
            expect(instance[k]).to eq(v.to_s)
          else
            expect(instance[k]).to_not be_a(String)
            expect(instance[k]).to eq(v)
          end
        end
      end

      it 'coerces Numeric to String' do
        subject.coerce_value Numeric, String

        {
          fixnum: 2,
          bignum: 12_345_667_890_987_654_321,
          float: 2.7,
          rational: Rational(2, 3),
          complex: Complex(1)
        }.each do |k, v|
          instance[k] = v
          expect(instance[k]).to be_a(String)
          expect(instance[k]).to eq(v.to_s)
        end
      end

      it 'can coerce via a proc' do
        subject.coerce_value(String, lambda do |v|
          return !!(v =~ /^(true|t|yes|y|1)$/i)
        end)

        true_values = %w(true t yes y 1)
        false_values = %w(false f no n 0)

        true_values.each do |v|
          instance[:foo] = v
          expect(instance[:foo]).to be_a(TrueClass)
        end
        false_values.each do |v|
          instance[:foo] = v
          expect(instance[:foo]).to be_a(FalseClass)
        end
      end
    end
  end

  after(:each) do
    Object.send(:remove_const, :ExampleCoercableHash)
  end
end
