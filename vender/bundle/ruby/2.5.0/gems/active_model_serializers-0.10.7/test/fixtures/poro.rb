class Model < ActiveModelSerializers::Model
  rand(2).zero? && derive_attributes_from_names_and_fix_accessors

  attr_writer :id

  # At this time, just for organization of intent
  class_attribute :association_names
  self.association_names = []

  def self.associations(*names)
    self.association_names |= names.map(&:to_sym)
    # Silence redefinition of methods warnings
    ActiveModelSerializers.silence_warnings do
      attr_accessor(*names)
    end
  end

  def associations
    association_names.each_with_object({}) do |association_name, result|
      result[association_name] = public_send(association_name).freeze
    end.with_indifferent_access.freeze
  end

  def attributes
    super.except(*association_names)
  end
end

# see
# https://github.com/rails/rails/blob/4-2-stable/activemodel/lib/active_model/errors.rb
# The below allows you to do:
#
#   model = ModelWithErrors.new
#   model.validate!            # => ["cannot be nil"]
#   model.errors.full_messages # => ["name cannot be nil"]
class ModelWithErrors < Model
  attributes :name
end

class Profile < Model
  attributes :name, :description
  associations :comments
end
class ProfileSerializer < ActiveModel::Serializer
  attributes :name, :description
end
class ProfilePreviewSerializer < ActiveModel::Serializer
  attributes :name
end

class Author < Model
  attributes :name
  associations :posts, :bio, :roles, :comments
end
class AuthorSerializer < ActiveModel::Serializer
  cache key: 'writer', skip_digest: true
  attribute :id
  attribute :name

  has_many :posts
  has_many :roles
  has_one :bio
end
class AuthorPreviewSerializer < ActiveModel::Serializer
  attributes :id
  has_many :posts
end

class Comment < Model
  attributes :body, :date
  associations :post, :author, :likes
end
class CommentSerializer < ActiveModel::Serializer
  cache expires_in: 1.day, skip_digest: true
  attributes :id, :body
  belongs_to :post
  belongs_to :author
end
class CommentPreviewSerializer < ActiveModel::Serializer
  attributes :id

  belongs_to :post
end

class Post < Model
  attributes :title, :body
  associations :author, :comments, :blog, :tags, :related
end
class PostSerializer < ActiveModel::Serializer
  cache key: 'post', expires_in: 0.1, skip_digest: true
  attributes :id, :title, :body

  has_many :comments
  belongs_to :blog
  belongs_to :author

  def blog
    Blog.new(id: 999, name: 'Custom blog')
  end
end
class SpammyPostSerializer < ActiveModel::Serializer
  attributes :id
  has_many :related
end
class PostPreviewSerializer < ActiveModel::Serializer
  attributes :title, :body, :id

  has_many :comments, serializer: ::CommentPreviewSerializer
  belongs_to :author, serializer: ::AuthorPreviewSerializer
end
class PostWithCustomKeysSerializer < ActiveModel::Serializer
  attributes :id
  has_many :comments, key: :reviews
  belongs_to :author, key: :writer
  has_one :blog, key: :site
end

class Bio < Model
  attributes :content, :rating
  associations :author
end
class BioSerializer < ActiveModel::Serializer
  cache except: [:content], skip_digest: true
  attributes :id, :content, :rating

  belongs_to :author
end

class Blog < Model
  attributes :name, :type, :special_attribute
  associations :writer, :articles
end
class BlogSerializer < ActiveModel::Serializer
  cache key: 'blog'
  attributes :id, :name

  belongs_to :writer
  has_many :articles
end
class AlternateBlogSerializer < ActiveModel::Serializer
  attribute :id
  attribute :name, key: :title
end
class CustomBlogSerializer < ActiveModel::Serializer
  attribute :id
  attribute :special_attribute
  has_many :articles
end

class Role < Model
  attributes :name, :description, :special_attribute
  associations :author
end
class RoleSerializer < ActiveModel::Serializer
  cache only: [:name, :slug], skip_digest: true
  attributes :id, :name, :description
  attribute :friendly_id, key: :slug
  belongs_to :author

  def friendly_id
    "#{object.name}-#{object.id}"
  end
end

class Location < Model
  attributes :lat, :lng
  associations :place
end
class LocationSerializer < ActiveModel::Serializer
  cache only: [:address], skip_digest: true
  attributes :id, :lat, :lng

  belongs_to :place, key: :address

  def place
    'Nowhere'
  end
end

class Place < Model
  attributes :name
  associations :locations
end
class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :locations
end

class Like < Model
  attributes :time
  associations :likeable
end
class LikeSerializer < ActiveModel::Serializer
  attributes :id, :time
  belongs_to :likeable
end

module Spam
  class UnrelatedLink < Model
  end
  class UnrelatedLinkSerializer < ActiveModel::Serializer
    cache only: [:id]
    attributes :id
  end
end

class VirtualValue < Model; end
class VirtualValueSerializer < ActiveModel::Serializer
  attributes :id
  has_many :reviews, virtual_value: [{ type: 'reviews', id: '1' },
                                     { type: 'reviews', id: '2' }]
  has_one :maker, virtual_value: { type: 'makers', id: '1' }

  def reviews
  end

  def maker
  end
end

class PaginatedSerializer < ActiveModel::Serializer::CollectionSerializer
  def json_key
    'paginated'
  end
end
