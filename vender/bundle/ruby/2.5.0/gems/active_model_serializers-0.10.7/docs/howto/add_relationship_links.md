[Back to Guides](../README.md)

# How to add relationship links

ActiveModelSerializers offers you many ways to add links in your JSON, depending on your needs.
The most common use case for links is supporting nested resources.

The following examples are without included relationship data (`include` param is empty),
specifically the following Rails controller was used for these examples:

```ruby
class Api::V1::UsersController < ApplicationController
  def show
    render jsonapi: User.find(params[:id]),
      serializer: Api::V1::UserSerializer,
      include: []
  end
end
```

Bear in mind though that ActiveModelSerializers are [framework-agnostic](outside_controller_use.md), Rails is just a common example here.

### Links as an attribute of a resource
**This is applicable to JSON and Attributes adapters**

You can define an attribute in the resource, named `links`.

```ruby
class Api::V1::UserSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :name

  attribute :links do
    id = object.id
    {
      self: api_v1_user_path(id),
      microposts: api_v1_microposts_path(user_id: id)
    }
  end
end
```

Using the `JSON` adapter, this will result in:

```json
{
  "user": {
    "id": "1",
    "name": "John",
    "links": {
      "self": "/api/v1/users/1",
      "microposts": "/api/v1/microposts?user_id=1"
    }
  }
}
```


### Links as a property of the resource definiton
**This is only applicable to JSONAPI adapter**

You can use the `link` class method to define the links you need in the resource's primary data.

```ruby
class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name

  link(:self) { api_v1_user_path(object.id) }
  link(:microposts) { api_v1_microposts_path(user_id: object.id) }
end
```

Using the `JSONAPI` adapter, this will result in:

```json
{
  "data": {
    "id": "1",
    "type": "users",
    "attributes": {
      "name": "Example User"
    },
    "links": {
      "self": "/api/v1/users/1",
      "microposts": "/api/v1/microposts?user_id=1"
    }
  }
}
```

### Links that follow the JSONAPI spec
**This is only applicable to JSONAPI adapter**

If you have a JSONAPI-strict client that you are working with (like `ember-data`)
you need to construct the links inside the relationships. Also the link to fetch the
relationship data must be under the `related` attribute, whereas to manipulate the
relationship (in case of many-to-many relationship) must be under the `self` attribute.

You can find more info in the [spec](http://jsonapi.org/format/#document-resource-object-relationships).

Here is how you can do this:

```ruby
class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :microposts, serializer: Api::V1::MicropostSerializer do
    link(:related) { api_v1_microposts_path(user_id: object.id) }

    microposts = object.microposts
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    microposts.loaded? ? microposts : microposts.none
  end
end
```

This will result in:

```json
{
  "data": {
    "id": "1",
    "type": "users",
    "attributes": {
      "name": "Example User"
    },
    "relationships": {
      "microposts": {
        "data": [],
        "links": {
          "related": "/api/v1/microposts?user_id=1"
        }
      }
    }
  }
}
```
