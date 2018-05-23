require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.define do
  self.verbose = false
  create_table :posts, force: true do |t|
    t.string :title
    t.text :body
    t.references :author
    t.timestamps null: false
  end
  create_table :authors, force: true do |t|
    t.string :name
    t.timestamps null: false
  end
  create_table :comments, force: true do |t|
    t.text :contents
    t.references :author
    t.references :post
    t.timestamp null: false
  end
  create_table :employees, force: true do |t|
    t.string :name
    t.string :email
    t.timestamp null: false
  end
  create_table :object_tags, force: true do |t|
    t.string :poly_tag_id
    t.string :taggable_type
    t.string :taggable_id
    t.timestamp null: false
  end
  create_table :poly_tags, force: true do |t|
    t.string :phrase
    t.timestamp null: false
  end
  create_table :pictures, force: true do |t|
    t.string :title
    t.string :imageable_type
    t.string :imageable_id
    t.timestamp null: false
  end
end

module ARModels
  class Post < ActiveRecord::Base
    has_many :comments
    belongs_to :author
  end
  class PostSerializer < ActiveModel::Serializer
    attributes :id, :title, :body

    has_many :comments
    belongs_to :author
  end

  class Comment < ActiveRecord::Base
    belongs_to :post
    belongs_to :author
  end
  class CommentSerializer < ActiveModel::Serializer
    attributes :id, :contents

    belongs_to :author
  end

  class Author < ActiveRecord::Base
    has_many :posts
  end
  class AuthorSerializer < ActiveModel::Serializer
    attributes :id, :name

    has_many :posts
  end
end

class Employee < ActiveRecord::Base
  has_many :pictures, as: :imageable
  has_many :object_tags, as: :taggable
end

class PolymorphicSimpleSerializer < ActiveModel::Serializer
  attributes :id
end

class ObjectTag < ActiveRecord::Base
  belongs_to :poly_tag
  belongs_to :taggable, polymorphic: true
end
class PolymorphicObjectTagSerializer < ActiveModel::Serializer
  attributes :id
  belongs_to :taggable, serializer: PolymorphicSimpleSerializer, polymorphic: true
end

class PolyTag < ActiveRecord::Base
  has_many :object_tags
end
class PolymorphicTagSerializer < ActiveModel::Serializer
  attributes :id, :phrase
  has_many :object_tags, serializer: PolymorphicObjectTagSerializer
end

class Picture < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
  has_many :object_tags, as: :taggable
end
class PolymorphicHasManySerializer < ActiveModel::Serializer
  attributes :id, :name
end
class PolymorphicBelongsToSerializer < ActiveModel::Serializer
  attributes :id, :title
  belongs_to :imageable, serializer: PolymorphicHasManySerializer, polymorphic: true
end
