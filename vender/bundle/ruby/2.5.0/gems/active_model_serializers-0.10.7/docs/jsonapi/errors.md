[Back to Guides](../README.md)

# [JSON API Errors](http://jsonapi.org/format/#errors)

Rendering error documents requires specifying the error serializer(s):

- Serializer:
  - For a single resource: `serializer: ActiveModel::Serializer::ErrorSerializer`.
  - For a collection: `serializer: ActiveModel::Serializer::ErrorsSerializer`, `each_serializer: ActiveModel::Serializer::ErrorSerializer`.

The resource **MUST** have a non-empty associated `#errors` object.
The `errors` object must have a `#messages` method that returns a hash of error name to array of
descriptions.

## Use in controllers

```ruby
resource = Profile.new(name: 'Name 1',
                       description: 'Description 1',
                       comments: 'Comments 1')
resource.errors.add(:name, 'cannot be nil')
resource.errors.add(:name, 'must be longer')
resource.errors.add(:id, 'must be a uuid')

render json: resource, status: 422, adapter: :json_api, serializer: ActiveModel::Serializer::ErrorSerializer
# #=>
#  { :errors =>
#    [
#      { :source => { :pointer => '/data/attributes/name' }, :detail => 'cannot be nil' },
#      { :source => { :pointer => '/data/attributes/name' }, :detail => 'must be longer' },
#      { :source => { :pointer => '/data/attributes/id' }, :detail => 'must be a uuid' }
#    ]
#  }.to_json
```

## Direct error document generation

```ruby
options = nil
resource = ModelWithErrors.new
resource.errors.add(:name, 'must be awesome')

serializable_resource = ActiveModelSerializers::SerializableResource.new(
  resource, {
    serializer: ActiveModel::Serializer::ErrorSerializer,
    adapter: :json_api
  })
serializable_resource.as_json(options)
# #=>
# {
#   :errors =>
#     [
#       { :source => { :pointer => '/data/attributes/name' }, :detail => 'must be awesome' }
#     ]
# }
```
