[Back to Guides](../README.md)

# How to add root key

Add the root key to your API is quite simple with ActiveModelSerializers. The **Adapter** is what determines the format of your JSON response. The default adapter is the ```Attributes``` which doesn't have the root key, so your response is something similar to:

```json
{
  "id": 1,
  "title": "Awesome Post Tile",
  "content": "Post content"
}
```

In order to add the root key you need to use the ```JSON``` Adapter, you can change this in an initializer:

```ruby
ActiveModelSerializers.config.adapter = :json
```

Note that adapter configuration has no effect on a serializer that is called
directly, e.g. in a serializer unit test. Instead, something like
`UserSerializer.new(user).as_json` will *always* behave as if the adapter were
the 'Attributes' adapter. See [Outside Controller
Usage](../howto/outside_controller_use.md) for more details on recommended
usage.

You can also specify a class as adapter, as long as it complies with the ActiveModelSerializers adapters interface.
It will add the root key to all your serialized endpoints.

ex:

```json
{
  "post": {
    "id": 1,
    "title": "Awesome Post Tile",
    "content": "Post content"
  }
}
```

or if it returns a collection:

```json
{
  "posts": [
    {
      "id": 1,
      "title": "Awesome Post Tile",
      "content": "Post content"
    },
    {
      "id": 2,
      "title": "Another Post Tile",
      "content": "Another post content"
    }
  ]
}
```

[There are several ways to specify root](../general/serializers.md#root) when using the JSON adapter.
