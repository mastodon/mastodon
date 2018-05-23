[Back to Guides](../README.md)

# Caching

## Warning

There is currently a problem with caching in AMS [Caching doesn't improve performance](https://github.com/rails-api/active_model_serializers/issues/1586). Adding caching _may_ slow down your application, rather than speeding it up. We suggest you benchmark any caching you implement before using in a production enviroment

___

To cache a serializer, call ```cache``` and pass its options.
The options are the same options of ```ActiveSupport::Cache::Store```, plus
a ```key``` option that will be the prefix of the object cache
on a pattern ```"#{key}/#{object.id}-#{object.updated_at}"```.

The cache support is optimized to use the cached object in multiple request. An object cached on a ```show``` request will be reused at the ```index```. If there is a relationship with another cached serializer it will also be created and reused automatically.

**[NOTE] Every object is individually cached.**

**[NOTE] The cache is automatically expired after an object is updated, but it's not deleted.**

```ruby
cache(options = nil) # options: ```{key, expires_in, compress, force, race_condition_ttl}```
```

Take the example below:

```ruby
class PostSerializer < ActiveModel::Serializer
  cache key: 'post', expires_in: 3.hours
  attributes :title, :body

  has_many :comments
end
```

On this example every ```Post``` object will be cached with
the key ```"post/#{post.id}-#{post.updated_at}"```. You can use this key to expire it as you want,
but in this case it will be automatically expired after 3 hours.

## Fragment Caching

If there is some API endpoint that shouldn't be fully cached, you can still optimise it, using Fragment Cache on the attributes and relationships that you want to cache.

You can define the attribute by using ```only``` or ```except``` option on cache method.

**[NOTE] Cache serializers will be used at their relationships**

Example:

```ruby
class PostSerializer < ActiveModel::Serializer
  cache key: 'post', expires_in: 3.hours, only: [:title]
  attributes :title, :body

  has_many :comments
end
```
