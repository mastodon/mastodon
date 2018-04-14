require 'spec_helper'

Hashie::Hash.class_eval do
  def self.inherited(klass)
    klass.instance_variable_set('@inheritance_test', true)
  end
end

class DashTest < Hashie::Dash
  property :first_name, required: true
  property :email
  property :count, default: 0
end

class DashTestDefaultProc < Hashie::Dash
  property :fields, default: -> { [] }
end

class DashNoRequiredTest < Hashie::Dash
  property :first_name
  property :email
  property :count, default: 0
end

class DashWithCoercion < Hashie::Dash
  include Hashie::Extensions::Coercion
  property :person
  property :city

  coerce_key :person, ::DashNoRequiredTest
end

class PropertyBangTest < Hashie::Dash
  property :important!
end

class SubclassedTest < DashTest
  property :last_name, required: true
end

class RequiredMessageTest < DashTest
  property :first_name, required: true, message: 'must be set.'
end

class DashDefaultTest < Hashie::Dash
  property :aliases, default: ['Snake']
end

class DeferredTest < Hashie::Dash
  property :created_at, default: proc { Time.now }
end

class DeferredWithSelfTest < Hashie::Dash
  property :created_at, default: -> { Time.now }
  property :updated_at, default: ->(test) { test.created_at }
end

describe DashTestDefaultProc do
  it 'as_json behaves correctly with default proc' do
    object = described_class.new
    expect(object.as_json).to be == { 'fields' => [] }
  end
end

describe DashTest do
  def property_required_error(property)
    [ArgumentError, "The property '#{property}' is required for #{subject.class.name}."]
  end

  def property_required_custom_error(property)
    [ArgumentError, "The property '#{property}' must be set."]
  end

  def property_message_without_required_error
    [ArgumentError, 'The :message option should be used with :required option.']
  end

  def no_property_error(property)
    [NoMethodError, "The property '#{property}' is not defined for #{subject.class.name}."]
  end

  subject { DashTest.new(first_name: 'Bob', email: 'bob@example.com') }
  let(:required_message) { RequiredMessageTest.new(first_name: 'Bob') }

  it('subclasses Hashie::Hash') { should respond_to(:to_mash) }

  describe '#to_s' do
    subject { super().to_s }
    it { should eq '#<DashTest count=0 email="bob@example.com" first_name="Bob">' }
  end

  it 'lists all set properties in inspect' do
    subject.first_name = 'Bob'
    subject.email = 'bob@example.com'
    expect(subject.inspect).to eq '#<DashTest count=0 email="bob@example.com" first_name="Bob">'
  end

  describe '#count' do
    subject { super().count }
    it { should be_zero }
  end

  it { should respond_to(:first_name) }
  it { should respond_to(:first_name=) }
  it { should_not respond_to(:nonexistent) }

  it 'errors out for a non-existent property' do
    expect { subject['nonexistent'] }.to raise_error(*no_property_error('nonexistent'))
  end

  it 'errors out when attempting to set a required property to nil' do
    expect { subject.first_name = nil }.to raise_error(*property_required_error('first_name'))
  end

  it 'errors out when message added to not required property' do
    expect do
      class DashMessageOptionWithoutRequiredTest < Hashie::Dash
        property :first_name, message: 'is required.'
      end
    end.to raise_error(*property_message_without_required_error)

    expect do
      class DashMessageOptionWithoutRequiredTest < Hashie::Dash
        property :first_name, required: false, message: 'is required.'
      end
    end.to raise_error(*property_message_without_required_error)
  end

  context 'writing to properties' do
    it 'fails writing a required property to nil' do
      expect { subject.first_name = nil }.to raise_error(*property_required_error('first_name'))
      expect { required_message.first_name = nil }.to raise_error(*property_required_custom_error('first_name'))
    end

    it 'fails writing a required property to nil using []=' do
      expect { subject[:first_name] = nil }.to raise_error(*property_required_error('first_name'))
      expect { required_message[:first_name] = nil }.to raise_error(*property_required_custom_error('first_name'))
    end

    it 'fails writing to a non-existent property using []=' do
      expect { subject['nonexistent'] = 123 }.to raise_error(*no_property_error('nonexistent'))
    end

    it 'works for an existing property using []=' do
      subject[:first_name] = 'Bob'
      expect(subject[:first_name]).to eq 'Bob'
      expect { subject['first_name'] }.to raise_error(*no_property_error('first_name'))
    end

    it 'works for an existing property using a method call' do
      subject.first_name = 'Franklin'
      expect(subject.first_name).to eq 'Franklin'
    end
  end

  context 'reading from properties' do
    it 'fails reading from a non-existent property using []' do
      expect { subject['nonexistent'] }.to raise_error(*no_property_error('nonexistent'))
    end

    it 'is able to retrieve properties through blocks' do
      subject[:first_name] = 'Aiden'
      value = nil
      subject.[](:first_name) { |v| value = v }
      expect(value).to eq 'Aiden'
    end

    it 'is able to retrieve properties through blocks with method calls' do
      subject[:first_name] = 'Frodo'
      value = nil
      subject.first_name { |v| value = v }
      expect(value).to eq 'Frodo'
    end
  end

  context 'reading from deferred properties' do
    it 'evaluates proc after initial read' do
      expect(DeferredTest.new[:created_at]).to be_instance_of(Time)
    end

    it 'does not evalute proc after subsequent reads' do
      deferred = DeferredTest.new
      expect(deferred[:created_at].object_id).to eq deferred[:created_at].object_id
    end
  end

  context 'reading from a deferred property based on context' do
    it 'provides the current hash as context for evaluation' do
      deferred = DeferredWithSelfTest.new
      expect(deferred[:created_at].object_id).to eq deferred[:created_at].object_id
      expect(deferred[:updated_at].object_id).to eq deferred[:created_at].object_id
    end
  end

  context 'converting from a Mash' do
    class ConvertingFromMash < Hashie::Dash
      property :property, required: true
    end

    context 'without keeping the original keys' do
      let(:mash) { Hashie::Mash.new(property: 'test') }

      it 'does not pick up the property from the stringified key' do
        expect { ConvertingFromMash.new(mash) }.to raise_error(NoMethodError)
      end
    end

    context 'when keeping the original keys' do
      class KeepingMash < Hashie::Mash
        include Hashie::Extensions::Mash::KeepOriginalKeys
      end

      let(:mash) { KeepingMash.new(property: 'test') }

      it 'picks up the property from the original key' do
        expect { ConvertingFromMash.new(mash) }.not_to raise_error
      end
    end
  end

  describe '#new' do
    it 'fails with non-existent properties' do
      expect { described_class.new(bork: '') }.to raise_error(*no_property_error('bork'))
    end

    it 'sets properties that it is able to' do
      obj = described_class.new first_name: 'Michael'
      expect(obj.first_name).to eq 'Michael'
    end

    it 'accepts nil' do
      expect { DashNoRequiredTest.new(nil) }.not_to raise_error
    end

    it 'accepts block to define a global default' do
      obj = described_class.new { |_, key| key.to_s.upcase }
      expect(obj.first_name).to eq 'FIRST_NAME'
      expect(obj.count).to be_zero
    end

    it 'fails when required values are missing' do
      expect { DashTest.new }.to raise_error(*property_required_error('first_name'))
    end

    it 'does not overwrite default values' do
      obj1 = DashDefaultTest.new
      obj1.aliases << 'El Rey'
      obj2 = DashDefaultTest.new
      expect(obj2.aliases).not_to include 'El Rey'
    end
  end

  describe '#merge' do
    it 'creates a new instance of the Dash' do
      new_dash = subject.merge(first_name: 'Robert')
      expect(subject.object_id).not_to eq new_dash.object_id
    end

    it 'merges the given hash' do
      new_dash = subject.merge(first_name: 'Robert', email: 'robert@example.com')
      expect(new_dash.first_name).to eq 'Robert'
      expect(new_dash.email).to eq 'robert@example.com'
    end

    it 'fails with non-existent properties' do
      expect { subject.merge(middle_name: 'James') }.to raise_error(*no_property_error('middle_name'))
    end

    it 'errors out when attempting to set a required property to nil' do
      expect { subject.merge(first_name: nil) }.to raise_error(*property_required_error('first_name'))
    end

    context 'given a block' do
      it "sets merged key's values to the block's return value" do
        expect(subject.merge(first_name: 'Jim') do |key, oldval, newval|
          "#{key}: #{newval} #{oldval}"
        end.first_name).to eq 'first_name: Jim Bob'
      end
    end
  end

  describe '#merge!' do
    it 'modifies the existing instance of the Dash' do
      original_dash = subject.merge!(first_name: 'Robert')
      expect(subject.object_id).to eq original_dash.object_id
    end

    it 'merges the given hash' do
      subject.merge!(first_name: 'Robert', email: 'robert@example.com')
      expect(subject.first_name).to eq 'Robert'
      expect(subject.email).to eq 'robert@example.com'
    end

    it 'fails with non-existent properties' do
      expect { subject.merge!(middle_name: 'James') }.to raise_error(NoMethodError)
    end

    it 'errors out when attempting to set a required property to nil' do
      expect { subject.merge!(first_name: nil) }.to raise_error(ArgumentError)
    end

    context 'given a block' do
      it "sets merged key's values to the block's return value" do
        expect(subject.merge!(first_name: 'Jim') do |key, oldval, newval|
          "#{key}: #{newval} #{oldval}"
        end.first_name).to eq 'first_name: Jim Bob'
      end
    end
  end

  describe 'properties' do
    it 'lists defined properties' do
      expect(described_class.properties).to eq Set.new([:first_name, :email, :count])
    end

    it 'checks if a property exists' do
      expect(described_class.property?(:first_name)).to be_truthy
      expect(described_class.property?('first_name')).to be_falsy
    end

    it 'checks if a property is required' do
      expect(described_class.required?(:first_name)).to be_truthy
      expect(described_class.required?('first_name')).to be_falsy
    end

    it 'doesnt include property from subclass' do
      expect(described_class.property?(:last_name)).to be_falsy
    end

    it 'lists declared defaults' do
      expect(described_class.defaults).to eq(count: 0)
    end

    it 'allows properties that end in bang' do
      expect(PropertyBangTest.property?(:important!)).to be_truthy
    end
  end

  describe '#replace' do
    before { subject.replace(first_name: 'Cain') }

    it 'return self' do
      expect(subject.replace(email: 'bar').to_hash).to eq(email: 'bar', count: 0)
    end

    it 'sets all specified keys to their corresponding values' do
      expect(subject.first_name).to eq 'Cain'
    end

    it 'leaves only specified keys and keys with default values' do
      expect(subject.keys.sort_by(&:to_s)).to eq [:count, :first_name]
      expect(subject.email).to be_nil
      expect(subject.count).to eq 0
    end

    context 'when replacing keys with default values' do
      before { subject.replace(count: 3) }

      it 'sets all specified keys to their corresponding values' do
        expect(subject.count).to eq 3
      end
    end
  end

  describe '#update_attributes!(params)' do
    let(:params) { { first_name: 'Alice', email: 'alice@example.com' } }

    context 'when there is coercion' do
      let(:params_before) { { city: 'nyc', person: { first_name: 'Bob', email: 'bob@example.com' } } }
      let(:params_after) { { city: 'sfo', person: { first_name: 'Alice', email: 'alice@example.com' } } }

      subject { DashWithCoercion.new(params_before) }

      it 'update the attributes' do
        expect(subject.person.first_name).to eq params_before[:person][:first_name]
        subject.update_attributes!(params_after)
        expect(subject.person.first_name).to eq params_after[:person][:first_name]
      end
    end

    it 'update the attributes' do
      subject.update_attributes!(params)
      expect(subject.first_name).to eq params[:first_name]
      expect(subject.email).to eq params[:email]
      expect(subject.count).to eq subject.class.defaults[:count]
    end

    context 'when required property is update to nil' do
      let(:params) { { first_name: nil, email: 'alice@example.com' } }

      it 'raise an ArgumentError' do
        expect { subject.update_attributes!(params) }.to raise_error(ArgumentError)
      end
    end

    context 'when a default property is update to nil' do
      let(:params) { { count: nil, email: 'alice@example.com' } }

      it 'set the property back to the default value' do
        subject.update_attributes!(params)
        expect(subject.email).to eq params[:email]
        expect(subject.count).to eq subject.class.defaults[:count]
      end
    end
  end
end

describe Hashie::Dash, 'inheritance' do
  before do
    @top = Class.new(Hashie::Dash)
    @middle = Class.new(@top)
    @bottom = Class.new(@middle)
  end

  it 'reports empty properties when nothing defined' do
    expect(@top.properties).to be_empty
    expect(@top.defaults).to be_empty
  end

  it 'inherits properties downwards' do
    @top.property :echo
    expect(@middle.properties).to include(:echo)
    expect(@bottom.properties).to include(:echo)
  end

  it 'doesnt inherit properties upwards' do
    @middle.property :echo
    expect(@top.properties).not_to include(:echo)
    expect(@bottom.properties).to include(:echo)
  end

  it 'allows overriding a default on an existing property' do
    @top.property :echo
    @middle.property :echo, default: 123
    expect(@bottom.properties.to_a).to eq [:echo]
    expect(@bottom.new.echo).to eq 123
  end

  it 'allows clearing an existing default' do
    @top.property :echo
    @middle.property :echo, default: 123
    @bottom.property :echo
    expect(@bottom.properties.to_a).to eq [:echo]
    expect(@bottom.new.echo).to be_nil
  end

  it 'allows nil defaults' do
    @bottom.property :echo, default: nil
    expect(@bottom.new).to have_key(:echo)
    expect(@bottom.new).to_not have_key('echo')
  end
end

describe SubclassedTest do
  subject { SubclassedTest.new(first_name: 'Bob', last_name: 'McNob', email: 'bob@example.com') }

  describe '#count' do
    subject { super().count }
    it { should be_zero }
  end

  it { should respond_to(:first_name) }
  it { should respond_to(:first_name=) }
  it { should respond_to(:last_name) }
  it { should respond_to(:last_name=) }

  it 'has one additional property' do
    expect(described_class.property?(:last_name)).to be_truthy
  end

  it "didn't override superclass inheritance logic" do
    expect(described_class.instance_variable_get('@inheritance_test')).to be_truthy
  end
end

class ConditionallyRequiredTest < Hashie::Dash
  property :username
  property :password, required: -> { !username.nil? }, message: 'must be set, too.'
end

describe ConditionallyRequiredTest do
  it 'does not allow a conditionally required property to be set to nil if required' do
    expect { ConditionallyRequiredTest.new(username: 'bob.smith', password: nil) }.to raise_error(ArgumentError, "The property 'password' must be set, too.")
  end

  it 'allows a conditionally required property to be set to nil if not required' do
    expect { ConditionallyRequiredTest.new(username: nil, password: nil) }.not_to raise_error
  end

  it 'allows a conditionally required property to be set if required' do
    expect { ConditionallyRequiredTest.new(username: 'bob.smith', password: '$ecure!') }.not_to raise_error
  end
end

class MixedPropertiesTest < Hashie::Dash
  property :symbol
  property 'string'
end

describe MixedPropertiesTest do
  subject { MixedPropertiesTest.new('string' => 'string', symbol: 'symbol') }

  it { should respond_to('string') }
  it { should respond_to(:symbol) }

  it 'property?' do
    expect(described_class.property?('string')).to be_truthy
    expect(described_class.property?(:symbol)).to be_truthy
  end

  it 'fetch' do
    expect(subject['string']).to eq('string')
    expect { subject[:string] }.to raise_error(NoMethodError)
    expect(subject[:symbol]).to eq('symbol')
    expect { subject['symbol'] }.to raise_error(NoMethodError)
  end

  it 'double define' do
    klass = Class.new(MixedPropertiesTest) do
      property 'symbol'
    end
    instance = klass.new(symbol: 'one', 'symbol' => 'two')
    expect(instance[:symbol]).to eq('one')
    expect(instance['symbol']).to eq('two')
  end

  it 'assign' do
    subject['string'] = 'updated'
    expect(subject['string']).to eq('updated')

    expect { subject[:string] = 'updated' }.to raise_error(NoMethodError)

    subject[:symbol] = 'updated'
    expect(subject[:symbol]).to eq('updated')

    expect { subject['symbol'] = 'updated' }.to raise_error(NoMethodError)
  end
end

context 'Dynamic Dash Class' do
  it 'define property' do
    klass       = Class.new(Hashie::Dash)
    my_property = 'my_property'
    my_orig     = my_property.dup

    klass.property(my_property)

    expect(my_property).to eq(my_orig)
  end
end

context 'with method access' do
  class DashWithMethodAccess < Hashie::Dash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::MethodQuery

    property :test
  end

  subject(:dash) { DashWithMethodAccess.new(test: 'value') }

  describe '#test' do
    subject { dash.test }

    it { is_expected.to eq('value') }
  end

  describe '#test?' do
    subject { dash.test? }

    it { is_expected.to eq true }
  end
end
