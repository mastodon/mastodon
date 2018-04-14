require "spec_helper"

class Service
  def single_associations
    FogSingleAssociationCollection.new
  end

  def multiple_associations
    FogMultipleAssociationsCollection.new
  end
end

class FogSingleAssociationModel < Fog::Model
  identity  :id
  attribute :name,  :type => :string
end

class FogMultipleAssociationsModel < Fog::Model
  identity  :id
  attribute :name,  :type => :string
end

class FogSingleAssociationCollection
  def get(id)
    FogSingleAssociationModel.new(:id => id)
  end
end

class FogMultipleAssociationsCollection < Fog::Association
  model FogMultipleAssociationsModel

  def get(id)
    FogMultipleAssociationsModel.new(:id => id)
  end
end

class FogAttributeTestModel < Fog::Model
  identity  :id
  attribute :key, :aliases => "keys", :squash => "id"
  attribute :time, :type => :time
  attribute :bool, :type => :boolean
  attribute :float, :type => :float
  attribute :integer, :type => :integer
  attribute :string, :type => :string
  attribute :timestamp, :type => :timestamp
  attribute :array, :type => :array
  attribute :default, :default => "default_value", :aliases => :some_name
  attribute :another_default, :default => false
  attribute :good_name, :as => :Badname

  has_one :one_object, :single_associations, :aliases => :single
  has_many :many_objects, :multiple_associations
  has_many :objects, :multiple_associations, :association_class => FogMultipleAssociationsCollection
  has_one_identity :one_identity, :single_associations, :as => :Crazyname
  has_many_identities :many_identities, :multiple_associations, :aliases => :multiple
  has_many_identities :identities, :multiple_associations, :association_class => FogMultipleAssociationsCollection

  def service
    Service.new
  end

  def requires_one_test
    requires_one :key, :time
  end

  def requires_test
    requires :string, :integer
  end
end

describe "Fog::Attributes" do
  let(:model) { FogAttributeTestModel.new }

  it "should not create alias for nil" do
    refute FogAttributeTestModel.aliases.keys.include?(nil)
  end

  describe "squash 'id'" do
    it "squashes if the key is a String" do
      model.merge_attributes("keys" => { :id => "value" })
      assert_equal "value", model.key
    end

    it "squashes if the key is a Symbol" do
      model.merge_attributes("keys" => { "id" => "value" })
      assert_equal "value", model.key
    end
  end

  describe ":type => time" do
    it "returns nil when provided nil" do
      model.merge_attributes(:time => nil)
      refute model.time
    end

    it "returns '' when provided ''" do
      model.merge_attributes(:time => "")
      assert_equal "",  model.time
    end

    it "returns a Time object when passed a Time object" do
      now = Time.now
      model.merge_attributes(:time => now.to_s)
      assert_equal Time.parse(now.to_s), model.time
    end

    it "returns a Time object when passed a string that is monkeypatched" do
      now = Time.now
      string = now.to_s
      def string.to_time
        "<3 <3 <3"
      end
      model.merge_attributes(:time => string)
      assert_equal Time.parse(string), model.time
    end
  end

  describe ":type => :boolean" do
    it "returns the String 'true' as a boolean" do
      model.merge_attributes(:bool => "true")
      assert_equal true, model.bool
    end

    it "returns true as true" do
      model.merge_attributes(:bool => true)
      assert_equal true, model.bool
    end

    it "returns the String 'false' as a boolean" do
      model.merge_attributes(:bool => "false")
      assert_equal false, model.bool
    end

    it "returns false as false" do
      model.merge_attributes(:bool => false)
      assert_equal false, model.bool
    end

    it "returns a non-true/false value as nil" do
      model.merge_attributes(:bool => "foo")
      refute model.bool
    end
  end

  describe ":type => :float" do
    it "returns an integer as float" do
      model.merge_attributes(:float => 1)
      assert_in_delta 1.0, model.float
    end

    it "returns a string as float" do
      model.merge_attributes(:float => "1")
      assert_in_delta 1.0, model.float
    end
  end

  describe ":type => :integer" do
    it "returns a float as integer" do
      model.merge_attributes(:integer => 1.5)
      assert_in_delta 1, model.integer
    end

    it "returns a string as integer" do
      model.merge_attributes(:integer => "1")
      assert_in_delta 1, model.integer
    end
  end

  describe ":type => :string" do
    it "returns a float as string" do
      model.merge_attributes(:string => 1.5)
      assert_equal "1.5", model.string
    end

    it "returns a integer as string" do
      model.merge_attributes(:string => 1)
      assert_equal "1", model.string
    end
  end

  describe ":type => :timestamp" do
    it "returns a date as time" do
      model.merge_attributes(:timestamp => Date.new(2008, 10, 12))
      assert_equal "2008-10-12 00:00", model.timestamp.strftime("%Y-%m-%d %M:%S")
      assert_instance_of Fog::Time, model.timestamp
    end

    it "returns a time as time" do
      model.merge_attributes(:timestamp => Time.mktime(2007, 11, 1, 15, 25))
      assert_equal "2007-11-01 25:00", model.timestamp.strftime("%Y-%m-%d %M:%S")
      assert_instance_of Fog::Time, model.timestamp
    end

    it "returns a date_time as time" do
      model.merge_attributes(:timestamp => DateTime.new(2007, 11, 1, 15, 25, 0))
      assert_equal "2007-11-01 25:00", model.timestamp.strftime("%Y-%m-%d %M:%S")
      assert_instance_of Fog::Time, model.timestamp
    end
  end

  describe ":type => :array" do
    it "returns an empty array when not initialized" do
      assert_equal [], model.array
    end

    it "returns an empty array as an empty array" do
      model.merge_attributes(:array => [])
      assert_equal [], model.array
    end

    it "returns nil as an empty array" do
      model.merge_attributes(:array => nil)
      assert_equal [], model.array
    end

    it "returns an array with nil as an array with nil" do
      model.merge_attributes(:array => [nil])
      assert_equal [nil], model.array
    end

    it "returns a single element as array" do
      model.merge_attributes(:array => 1.5)
      assert_equal [1.5], model.array
    end

    it "returns an array as array" do
      model.merge_attributes(:array => [1, 2])
      assert_equal [1, 2], model.array
    end
  end

  describe ":default => 'default_value'" do
    it "should return nil when default is not defined on a new object" do
      assert_nil model.bool
    end

    it "should return the value of the object when default is not defined" do
      model.merge_attributes(:bool => false)
      assert_equal model.bool, false
    end

    it "should return the default value on a new object with value equal nil" do
      assert_equal model.default, "default_value"
    end

    it "should return the value on a new object with value not equal nil" do
      model.default = "not default"
      assert_equal model.default, "not default"
    end

    it "should return false when default value is false on a new object" do
      assert_equal model.another_default, false
    end

    it "should return the value of the persisted object" do
      model.merge_attributes(:id => "some-crazy-id", :default => 23)
      assert_equal model.default, 23
    end

    it "should return nil on a persisted object without a value" do
      model.merge_attributes(:id => "some-crazy-id")
      assert_nil model.default
    end

    it "should return nil when an attribute with default value is setted to nil" do
      model.default = nil
      assert_nil model.default
    end
  end

  describe ".has_one" do
    it "should create an instance_variable to save the association object" do
      assert_nil model.one_object
    end

    it "should create a getter to save the association model" do
      model.merge_attributes(:one_object => FogSingleAssociationModel.new(:id => "123"))
      assert_instance_of FogSingleAssociationModel, model.one_object
      assert_equal model.one_object.attributes, :id => "123"
    end

    it "should create a setter that accept an object as param" do
      model.one_object = FogSingleAssociationModel.new(:id => "123")
      assert_equal model.one_object.attributes, :id => "123"
    end

    it "should create an alias to single" do
      model.merge_attributes(:single => FogSingleAssociationModel.new(:id => "123"))
      assert_equal model.one_object.attributes, :id => "123"
    end
  end

  describe ".has_one_identity" do
    it "should create an instance_variable to save the association identity" do
      assert_nil model.one_identity
    end

    it "should create a getter to load the association model" do
      model.merge_attributes(:one_identity => "123")
      assert_instance_of FogSingleAssociationModel, model.one_identity
      assert_equal model.one_identity.attributes, :id => "123"
    end

    describe "should create a setter that accept" do
      it "an id as param" do
        model.one_identity = "123"
        assert_equal model.one_identity.attributes, :id => "123"
      end

      it "a model as param" do
        model.one_identity = FogSingleAssociationModel.new(:id => "123")
        assert_equal model.one_identity.attributes, :id => "123"
      end
    end
  end

  describe ".has_many" do
    it "should return an instance of Fog::Association" do
      model.many_objects = [FogMultipleAssociationsModel.new(:id => "456")]
      assert_instance_of Fog::Association, model.many_objects
    end

    it "should create an instance_variable to save the associated objects" do
      assert_equal model.many_objects, []
    end

    it "should create a getter to save all associated models" do
      model.merge_attributes(:many_objects => [FogMultipleAssociationsModel.new(:id => "456")])
      assert_instance_of Fog::Association, model.many_objects
      assert_equal model.many_objects.size, 1
      assert_instance_of FogMultipleAssociationsModel, model.many_objects.first
      assert_equal model.many_objects.first.attributes, :id => "456"
    end

    it "should create a setter that accept an array of objects as param" do
      model.many_objects = [FogMultipleAssociationsModel.new(:id => "456")]
      assert_equal model.many_objects.first.attributes, :id => "456"
    end

    describe "with a custom collection class" do
      it "should return an instance of that collection class" do
        model.objects = [FogMultipleAssociationsModel.new(:id => "456")]
        assert_instance_of FogMultipleAssociationsCollection, model.objects
      end
    end
  end

  describe "#requires_one" do
    it "should require at least one attribute is supplied" do
      FogAttributeTestModel.new(:key => :key, :time => Time.now).requires_one_test
      FogAttributeTestModel.new(:time => Time.now).requires_one_test
      FogAttributeTestModel.new(:key => :key).requires_one_test
      FogAttributeTestModel.new(:key => :key, :integer => 1).requires_one_test

      assert_raises ArgumentError do
        FogAttributeTestModel.new(:integer => 1).requires_one_test
      end
    end
  end

  describe "#requires" do
    it "should require all attributes are supplied" do
      FogAttributeTestModel.new(:string => "string", :integer => 1).requires_test

      assert_raises ArgumentError do
        FogAttributeTestModel.new(:integer => 1).requires_test
      end

      assert_raises ArgumentError do
        FogAttributeTestModel.new(:string => "string").requires_test
      end

      assert_raises ArgumentError do
        FogAttributeTestModel.new(:key => :key).requires_test
      end
    end
  end

  describe ".has_many_identities" do
    it "should return an instance of Fog::Association" do
      model.many_identities = ["456"]
      assert_instance_of Fog::Association, model.many_identities
    end

    it "should create an instance_variable to save the associations identities" do
      assert_equal model.many_identities, []
    end

    it "should create a getter to load all association models" do
      model.merge_attributes(:many_identities => ["456"])
      assert_instance_of Fog::Association, model.many_identities
      assert_equal model.many_identities.size, 1
      assert_instance_of FogMultipleAssociationsModel, model.many_identities.first
      assert_equal model.many_identities.first.attributes, :id => "456"
    end

    describe "should create a setter that accept an array of" do
      it "ids as param" do
        model.many_identities = ["456"]
        assert_equal model.many_identities.first.attributes, :id => "456"
      end

      it "models as param" do
        model.many_identities = [FogMultipleAssociationsModel.new(:id => "456")]
        assert_equal model.many_identities.first.attributes, :id => "456"
      end
    end

    it "should create an alias to multiple" do
      model.merge_attributes(:multiple => ["456"])
      assert_equal model.many_identities.first.attributes, :id => "456"
    end

    describe "with a custom collection class" do
      it "should return an instance of that collection class" do
        model.identities = ["456"]
        assert_instance_of FogMultipleAssociationsCollection, model.identities
      end
    end
  end

  describe "#all_attributes" do
    describe "on a persisted object" do
      it "should return all attributes without default values" do
        model.merge_attributes(:id => 2, :float => 3.2, :integer => 55_555_555)
        assert model.persisted?
        assert_equal model.all_attributes,   :id => 2,
                                             :key => nil,
                                             :time => nil,
                                             :bool => nil,
                                             :float => 3.2,
                                             :integer => 55_555_555,
                                             :string => nil,
                                             :timestamp => nil,
                                             :array => [],
                                             :default => nil,
                                             :another_default => nil,
                                             :Badname => nil
      end
    end

    describe "on a new object" do
      it "should return all attributes including default values for empty attributes" do
        model.merge_attributes(:float => 3.2, :integer => 55_555_555)
        refute model.persisted?
        assert_equal model.all_attributes,   :id => nil,
                                             :key => nil,
                                             :time => nil,
                                             :bool => nil,
                                             :float => 3.2,
                                             :integer => 55_555_555,
                                             :string => nil,
                                             :timestamp => nil,
                                             :array => [],
                                             :default => "default_value",
                                             :another_default => false,
                                             :Badname => nil
      end
    end
  end

  describe "#all_associations" do
    describe "without any association" do
      it "should return all associations empty" do
        assert_equal model.all_associations, :one_object => nil,
                                             :many_objects => [],
                                             :Crazyname => nil,
                                             :many_identities => [],
                                             :objects => [],
                                             :identities => []
      end
    end

    describe "with associations" do
      it "should return all association objects" do
        @one_object = FogMultipleAssociationsModel.new
        @many_objects = [@one_object]
        model.merge_attributes(:one_object => @one_object, :many_objects => @many_objects)
        model.merge_attributes(:one_identity => "XYZ", :many_identities => %w(ABC))
        assert_equal model.all_associations,   :one_object => @one_object,
                                               :many_objects => @many_objects,
                                               :Crazyname => "XYZ",
                                               :many_identities => %w(ABC),
                                               :objects => [],
                                               :identities => []
      end
    end
  end

  describe "#all_associations_and_attributes" do
    describe "on a persisted object" do
      it "should return all association and attributes but no default values" do
        @one_object = FogMultipleAssociationsModel.new
        @many_objects = [@one_object]
        model.merge_attributes(:id => 2, :float => 3.2, :integer => 55_555_555)
        model.merge_attributes(:one_object => @one_object, :many_objects => @many_objects)
        model.merge_attributes(:one_identity => "XYZ", :many_identities => %w(ABC))
        assert model.persisted?
        assert_equal model.all_associations_and_attributes,  :id => 2,
                                                             :key => nil,
                                                             :time => nil,
                                                             :bool => nil,
                                                             :float => 3.2,
                                                             :integer => 55_555_555,
                                                             :string => nil,
                                                             :timestamp => nil,
                                                             :array => [],
                                                             :default => nil,
                                                             :another_default => nil,
                                                             :Badname => nil,
                                                             :one_object => @one_object,
                                                             :many_objects => @many_objects,
                                                             :objects => [],
                                                             :identities => [],
                                                             :Crazyname => "XYZ",
                                                             :many_identities => %w(ABC)
      end
    end

    describe "on a non persisted object" do
      it "should return all association and attributes and the default value for blank attributes" do
        @one_object = FogMultipleAssociationsModel.new
        @many_objects = [@one_object]
        model.merge_attributes(:float => 3.2, :integer => 55_555_555)
        model.merge_attributes(:one_object => @one_object, :many_objects => @many_objects)
        model.merge_attributes(:one_identity => "XYZ", :many_identities => %w(ABC))
        refute model.persisted?
        assert_equal model.all_associations_and_attributes,  :id => nil,
                                                             :key => nil,
                                                             :time => nil,
                                                             :bool => nil,
                                                             :float => 3.2,
                                                             :integer => 55_555_555,
                                                             :string => nil,
                                                             :timestamp => nil,
                                                             :array => [],
                                                             :default => "default_value",
                                                             :another_default => false,
                                                             :Badname => nil,
                                                             :one_object => @one_object,
                                                             :many_objects => @many_objects,
                                                             :objects => [],
                                                             :identities => [],
                                                             :Crazyname => "XYZ",
                                                             :many_identities => %w(ABC)
      end
    end
  end
end
