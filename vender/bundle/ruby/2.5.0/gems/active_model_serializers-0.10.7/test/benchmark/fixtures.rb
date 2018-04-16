Rails.configuration.serializers = []
class HasOneRelationshipSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name

  has_many :primary_resources, embed: :ids
  has_one :bio
end
Rails.configuration.serializers << HasOneRelationshipSerializer

class VirtualAttributeSerializer < ActiveModel::Serializer
  attributes :id, :name
end
Rails.configuration.serializers << VirtualAttributeSerializer

class HasManyRelationshipSerializer < ActiveModel::Serializer
  attributes :id, :body

  belongs_to :primary_resource
  belongs_to :has_one_relationship
end
Rails.configuration.serializers << HasManyRelationshipSerializer

class PrimaryResourceSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  has_many :has_many_relationships, serializer: HasManyRelationshipSerializer
  belongs_to :virtual_attribute, serializer: VirtualAttributeSerializer
  belongs_to :has_one_relationship, serializer: HasOneRelationshipSerializer

  link(:primary_resource_has_one_relationships) { 'https://example.com/primary_resource_has_one_relationships' }

  meta do
    {
      rating: 5,
      favorite_count: 10
    }
  end

  def virtual_attribute
    VirtualAttribute.new(id: 999, name: 'Free-Range Virtual Attribute')
  end
end
Rails.configuration.serializers << PrimaryResourceSerializer

class CachingHasOneRelationshipSerializer < HasOneRelationshipSerializer
  cache key: 'writer', skip_digest: true
end
Rails.configuration.serializers << CachingHasOneRelationshipSerializer

class CachingHasManyRelationshipSerializer < HasManyRelationshipSerializer
  cache expires_in: 1.day, skip_digest: true
end
Rails.configuration.serializers << CachingHasManyRelationshipSerializer

# see https://github.com/rails-api/active_model_serializers/pull/1690/commits/68715b8f99bc29677e8a47bb3f305f23c077024b#r60344532
class CachingPrimaryResourceSerializer < ActiveModel::Serializer
  cache key: 'primary_resource', expires_in: 0.1, skip_digest: true

  attributes :id, :title, :body

  belongs_to :virtual_attribute, serializer: VirtualAttributeSerializer
  belongs_to :has_one_relationship, serializer: CachingHasOneRelationshipSerializer
  has_many :has_many_relationships, serializer: CachingHasManyRelationshipSerializer

  link(:primary_resource_has_one_relationships) { 'https://example.com/primary_resource_has_one_relationships' }

  meta do
    {
      rating: 5,
      favorite_count: 10
    }
  end

  def virtual_attribute
    VirtualAttribute.new(id: 999, name: 'Free-Range Virtual Attribute')
  end
end
Rails.configuration.serializers << CachingPrimaryResourceSerializer

class FragmentCachingHasOneRelationshipSerializer < HasOneRelationshipSerializer
  cache key: 'writer', only: [:first_name, :last_name], skip_digest: true
end
Rails.configuration.serializers << FragmentCachingHasOneRelationshipSerializer

class FragmentCachingHasManyRelationshipSerializer < HasManyRelationshipSerializer
  cache expires_in: 1.day, except: [:body], skip_digest: true
end
Rails.configuration.serializers << CachingHasManyRelationshipSerializer

# see https://github.com/rails-api/active_model_serializers/pull/1690/commits/68715b8f99bc29677e8a47bb3f305f23c077024b#r60344532
class FragmentCachingPrimaryResourceSerializer < ActiveModel::Serializer
  cache key: 'primary_resource', expires_in: 0.1, skip_digest: true

  attributes :id, :title, :body

  belongs_to :virtual_attribute, serializer: VirtualAttributeSerializer
  belongs_to :has_one_relationship, serializer: FragmentCachingHasOneRelationshipSerializer
  has_many :has_many_relationships, serializer: FragmentCachingHasManyRelationshipSerializer

  link(:primary_resource_has_one_relationships) { 'https://example.com/primary_resource_has_one_relationships' }

  meta do
    {
      rating: 5,
      favorite_count: 10
    }
  end

  def virtual_attribute
    VirtualAttribute.new(id: 999, name: 'Free-Range Virtual Attribute')
  end
end
Rails.configuration.serializers << FragmentCachingPrimaryResourceSerializer

if ENV['ENABLE_ACTIVE_RECORD'] == 'true'
  require 'active_record'

  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  ActiveRecord::Schema.define do
    self.verbose = false

    create_table :virtual_attributes, force: true do |t|
      t.string :name
      t.timestamps null: false
    end
    create_table :has_one_relationships, force: true do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps null: false
    end
    create_table :primary_resources, force: true do |t|
      t.string :title
      t.text :body
      t.references :has_one_relationship
      t.references :virtual_attribute
      t.timestamps null: false
    end
    create_table :has_many_relationships, force: true do |t|
      t.text :body
      t.references :has_one_relationship
      t.references :primary_resource
      t.timestamps null: false
    end
  end

  class HasManyRelationship < ActiveRecord::Base
    belongs_to :has_one_relationship
    belongs_to :primary_resource
  end

  class HasOneRelationship < ActiveRecord::Base
    has_many :primary_resources
    has_many :has_many_relationships
  end

  class PrimaryResource < ActiveRecord::Base
    has_many :has_many_relationships
    belongs_to :has_one_relationship
    belongs_to :virtual_attribute
  end

  class VirtualAttribute < ActiveRecord::Base
    has_many :primary_resources
  end
else
  # ActiveModelSerializers::Model is a convenient
  # serializable class to inherit from when making
  # serializable non-activerecord objects.
  class BenchmarkModel
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes
      super
    end

    # Defaults to the downcased model name.
    def id
      attributes.fetch(:id) { self.class.name.downcase }
    end

    # Defaults to the downcased model name and updated_at
    def cache_key
      attributes.fetch(:cache_key) { "#{self.class.name.downcase}/#{id}" }
    end

    # Defaults to the time the serializer file was modified.
    def updated_at
      @updated_at ||= attributes.fetch(:updated_at) { File.mtime(__FILE__) }
    end

    def read_attribute_for_serialization(key)
      if key == :id || key == 'id'
        attributes.fetch(key) { id }
      else
        attributes[key]
      end
    end
  end

  class HasManyRelationship < BenchmarkModel
    attr_accessor :id, :body
  end

  class HasOneRelationship < BenchmarkModel
    attr_accessor :id, :first_name, :last_name, :primary_resources
  end

  class PrimaryResource < BenchmarkModel
    attr_accessor :id, :title, :body, :has_many_relationships, :virtual_attribute, :has_one_relationship
  end

  class VirtualAttribute < BenchmarkModel
    attr_accessor :id, :name
  end
end
