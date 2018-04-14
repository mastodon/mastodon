[Back to Guides](../README.md)

# Serializers

Given a serializer class:

```ruby
class SomeSerializer < ActiveModel::Serializer
end
```

The following methods may be defined in it:

### Attributes

#### ::attributes

Serialization of the resource `title` and `body`

| In Serializer               | #attributes |
|---------------------------- |-------------|
| `attributes :title, :body`  | `{ title: 'Some Title', body: 'Some Body' }`
| `attributes :title, :body`<br>`def body "Special #{object.body}" end` | `{ title: 'Some Title', body: 'Special Some Body' }`


#### ::attribute

Serialization of the resource `title`

| In Serializer               | #attributes |
|---------------------------- |-------------|
| `attribute :title`          | `{ title: 'Some Title' } `
| `attribute :title, key: :name` | `{ name: 'Some Title' } `
| `attribute(:title) { 'A Different Title'}` | `{ title: 'A Different Title' } `
| `attribute :title`<br>`def title 'A Different Title' end` | `{ title: 'A Different Title' }`

An `if` or `unless` option can make an attribute conditional. It takes a symbol of a method name on the serializer, or a lambda literal.

e.g.

```ruby
attribute :private_data, if: :is_current_user?
attribute :another_private_data, if: -> { scope.admin? }

def is_current_user?
  object.id == current_user.id
end
```

### Associations

The interface for associations is, generically:

> `association_type(association_name, options, &block)`

Where:

- `association_type` may be `has_one`, `has_many`, `belongs_to`.
- `association_name` is a method name the serializer calls.
- optional: `options` may be:
  - `key:` The name used for the serialized association.
  - `serializer:`
  - `if:`
  - `unless:`
  - `virtual_value:`
  - `polymorphic:` defines if polymorphic relation type should be nested in serialized association.
  - `type:` the resource type as used by JSON:API, especially on a `belongs_to` relationship.
  - `class_name:` used to determine `type` when `type` not given
  - `foreign_key:` used by JSON:API on a `belongs_to` relationship to avoid unnecessarily loading the association object.
  - `namespace:` used when looking up the serializer and `serializer` is not given.  Falls back to the parent serializer's `:namespace` instance options, which, when present, comes from the render options. See [Rendering#namespace](rendering.md#namespace] for more details.
- optional: `&block` is a context that returns the association's attributes.
  - prevents `association_name` method from being called.
  - return value of block is used as the association value.
  - yields the `serializer` to the block.
  - `include_data false` prevents the `data` key from being rendered in the JSON API relationship.

#### ::has_one

e.g.

```ruby
has_one :bio
has_one :blog, key: :site
has_one :maker, virtual_value: { id: 1 }

has_one :blog do |serializer|
  serializer.cached_blog
end

def cached_blog
  cache_store.fetch("cached_blog:#{object.updated_at}") do
    Blog.find(object.blog_id)
  end
end
```

```ruby
has_one :blog, if: :show_blog?
# you can also use a string or lambda
# has_one :blog, if: 'scope.admin?'
# has_one :blog, if: -> (serializer) { serializer.scope.admin? }
# has_one :blog, if: -> { scope.admin? }

def show_blog?
  scope.admin?
end
```

#### ::has_many

e.g.

```ruby
has_many :comments
has_many :comments, key: :reviews
has_many :comments, serializer: CommentPreviewSerializer
has_many :reviews, virtual_value: [{ id: 1 }, { id: 2 }]
has_many :comments, key: :last_comments do
  last(1)
end
```

#### ::belongs_to

e.g.

```ruby
belongs_to :author, serializer: AuthorPreviewSerializer
belongs_to :author, key: :writer
belongs_to :post
belongs_to :blog
def blog
  Blog.new(id: 999, name: 'Custom blog')
end
```

### Polymorphic Relationships

Polymorphic relationships are serialized by specifying the relationship, like any other association. For example:

```ruby
class PictureSerializer < ActiveModel::Serializer
  has_one :imageable
end
```

You can specify the serializers by [overriding serializer_for](serializers.md#overriding-association-serializer-lookup). For more context about polymorphic relationships, see the [tests](../../test/adapter/polymorphic_test.rb) for each adapter.

### Caching

#### ::cache

e.g.

```ruby
cache key: 'post', expires_in: 0.1, skip_digest: true
cache expires_in: 1.day, skip_digest: true
cache key: 'writer', skip_digest: true
cache only: [:name], skip_digest: true
cache except: [:content], skip_digest: true
cache key: 'blog'
cache only: [:id]
```

#### #cache_key

e.g.

```ruby
# Uses a custom non-time-based cache key
def cache_key
  "#{self.class.name.downcase}/#{self.id}"
end
```

### Other

#### ::type

When using the `:json_api` adapter, the `::type` method defines the JSONAPI [type](http://jsonapi.org/format/#document-resource-object-identification) that will be rendered for this serializer.

When using the `:json` adapter, the `::type` method defines the name of the root element.

It either takes a `String` or `Symbol` as parameter.

Note: This method is useful only when using the `:json_api` or `:json` adapter.

Examples:
```ruby
class UserProfileSerializer < ActiveModel::Serializer
  type 'profile'

  attribute :name
end
class AuthorProfileSerializer < ActiveModel::Serializer
  type :profile

  attribute :name
end
```

With the `:json_api` adapter, the previous serializers would be rendered as:

``` json
{
  "data": {
    "id": "1",
    "type": "profile",
    "attributes": {
      "name": "Julia"
    }
  }
}
```

With the `:json` adapter, the previous serializer would be rendered as:

``` json
{
  "profile": {
    "name": "Julia"
  }
}
```

#### ::link

```ruby
link :self do
  href "https://example.com/link_author/#{object.id}"
end
link(:author) { link_author_url(object) }
link(:link_authors) { link_authors_url }
link :other, 'https://example.com/resource'
link(:posts) { link_author_posts_url(object) }
```

#### #object

The object being serialized.

#### #root

Resource root which is included in `JSON` adapter. As you can see at [Adapters Document](adapters.md), `Attribute` adapter (default) and `JSON API` adapter does not include root at top level.
By default, the resource root comes from the `model_name` of the serialized object's class.

There are several ways to specify root:
* [Overriding the root key](rendering.md#overriding-the-root-key)
* [Setting `type`](serializers.md#type)
* Specifying the `root` option, e.g. `root: 'specific_name'`, during the serializer's initialization:

```ruby
ActiveModelSerializers::SerializableResource.new(foo, root: 'bar')
```

#### #scope

Allows you to include in the serializer access to an external method.

It's intended to provide an authorization context to the serializer, so that
you may e.g. show an admin all comments on a post, else only published comments.

- `scope` is a method on the serializer instance that comes from `options[:scope]`. It may be nil.
- `scope_name` is an option passed to the new serializer (`options[:scope_name]`).  The serializer
  defines a method with that name that calls the `scope`, e.g. `def current_user; scope; end`.
  Note: it does not define the method if the serializer instance responds to it.

That's a lot of words, so here's some examples:

First, let's assume the serializer is instantiated in the controller, since that's the usual scenario.
We'll refer to the serialization context as `controller`.

| options | `Serializer#scope` | method definition |
|-------- | ------------------|--------------------|
| `scope: current_user, scope_name: :current_user` | `current_user` | `Serializer#current_user` calls `controller.current_user`
| `scope: view_context, scope_name: :view_context` | `view_context` | `Serializer#view_context` calls `controller.view_context`

We can take advantage of the scope to customize the objects returned based
on the current user (scope).

For example, we can limit the posts the current user sees to those they created:

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  # scope comments to those created_by the current user
  has_many :comments do
    object.comments.where(created_by: current_user)
  end
end
```

Whether you write the method as above or as `object.comments.where(created_by: scope)`
is a matter of preference (assuming `scope_name` has been set).

Keep in mind that the scope can be set to any available controller reference. This can be utilized to provide access to any other data scopes or presentation helpers. 

##### Controller Authorization Context

In the controller, the scope/scope_name options are equal to
the [`serialization_scope`method](https://github.com/rails-api/active_model_serializers/blob/d02cd30fe55a3ea85e1d351b6e039620903c1871/lib/action_controller/serialization.rb#L13-L20),
which is `:current_user`, by default.

Specifically, the `scope_name` is defaulted to `:current_user`, and may be set as
`serialization_scope :view_context`.  The `scope` is set to `send(scope_name)` when `scope_name` is
present and the controller responds to `scope_name`.

Thus, in a serializer, the controller provides `current_user` as the
current authorization scope when you call `render :json`.

**IMPORTANT**: Since the scope is set at render, you may want to customize it so that `current_user` isn't
called on every request.  This was [also a problem](https://github.com/rails-api/active_model_serializers/pull/1252#issuecomment-159810477)
in [`0.9`](https://github.com/rails-api/active_model_serializers/tree/0-9-stable#customizing-scope).

We can change the scope from `current_user` to `view_context`, which is included in subclasses of `ActionController::Base`.

```diff
class SomeController < ActionController::Base
+  serialization_scope :view_context

  def current_user
    User.new(id: 2, name: 'Bob', admin: true)
  end

  def edit
    user = User.new(id: 1, name: 'Pete')
    render json: user, serializer: AdminUserSerializer, adapter: :json_api
  end
end
```

We could then use the controller method `view_context` in our serializer, like so:

```diff
class AdminUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :can_edit

  def can_edit?
+    view_context.current_user.admin?
  end
end
```

So that when we render the `#edit` action, we'll get

```json
{"data":{"id":"1","type":"users","attributes":{"name":"Pete","can_edit":true}}}
```

Where `can_edit` is `view_context.current_user.admin?` (true).

You can also tell what to set as `serialization_scope` for specific actions.

For example, use `admin_user` only for `Admin::PostSerializer` and `current_user` for rest.

```ruby
class PostsController < ActionController::Base

  before_action only: :edit do
    self.class.serialization_scope :admin_user
  end

  def show
    render json: @post, serializer: PostSerializer
  end

  def edit
    @post.save
    render json: @post, serializer: Admin::PostSerializer
  end

  private

  def admin_user
    User.new(id: 2, name: 'Bob', admin: true)
  end

  def current_user
    User.new(id: 2, name: 'Bob', admin: false)
  end
end
```
Note that any controller reference which provides the desired scope is acceptable, such as another controller method for loading a different resource or reference to helpers. For example, `ActionController::API` does not include `ActionView::ViewContext`, and would need a different reference for passing any helpers into a serializer via `serialization_scope`. 

#### #read_attribute_for_serialization(key)

The serialized value for a given key. e.g. `read_attribute_for_serialization(:title) #=> 'Hello World'`

#### #links

Allows you to modify the `links` node. By default, this node will be populated with the attributes set using the [::link](#link) method. Using `links: nil` will remove the `links` node.

```ruby
ActiveModelSerializers::SerializableResource.new(
  @post,
  adapter: :json_api,
  links: {
    self: {
      href: 'http://example.com/posts',
      meta: {
        stuff: 'value'
      }
    }
  }
)
```

#### #json_key

Returns the key used by the adapter as the resource root. See [root](#root) for more information.

## Examples

Given two models, a `Post(title: string, body: text)` and a
`Comment(name: string, body: text, post_id: integer)`, you will have two
serializers:

```ruby
class PostSerializer < ActiveModel::Serializer
  cache key: 'posts', expires_in: 3.hours
  attributes :title, :body

  has_many :comments
end
```

and

```ruby
class CommentSerializer < ActiveModel::Serializer
  attributes :name, :body

  belongs_to :post
end
```

Generally speaking, you, as a user of ActiveModelSerializers, will write (or generate) these
serializer classes.

## More Info

For more information, see [the Serializer class on GitHub](https://github.com/rails-api/active_model_serializers/blob/master/lib/active_model/serializer.rb)

## Overriding association methods

To override an association, call `has_many`, `has_one` or `belongs_to` with a block:

```ruby
class PostSerializer < ActiveModel::Serializer
  has_many :comments do
    object.comments.active
  end
end
```

## Overriding attribute methods

To override an attribute, call `attribute` with a block:

```ruby
class PostSerializer < ActiveModel::Serializer
  attribute :body do
    object.body.downcase
  end
end
```

## Overriding association serializer lookup

If you want to define a specific serializer lookup for your associations, you can override
the `ActiveModel::Serializer.serializer_for` method to return a serializer class based on defined conditions.

```ruby
class MySerializer < ActiveModel::Serializer
  def self.serializer_for(model, options)
    return SparseAdminSerializer if model.class == 'Admin'
    super
  end

  # the rest of the serializer
end
```
