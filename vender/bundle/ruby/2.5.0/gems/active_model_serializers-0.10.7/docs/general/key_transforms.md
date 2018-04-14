[Back to Guides](../README.md)

# Key Transforms

Key Transforms modify the casing of keys and keys referenced in values in
serialized responses.

Provided key transforms:

| Option | Result |
|----|----|
| `:camel` | ExampleKey |
| `:camel_lower` | exampleKey |
| `:dash` | example-key |
| `:unaltered` | the original, unaltered key |
| `:underscore` | example_key |
| `nil` | use the adapter default |

Key translation precedence is as follows:

##### Adapter option

`key_transform` is provided as an option via render.

```render json: posts, each_serializer: PostSerializer, key_transform: :camel_lower```

##### Configuration option

`key_transform` is set in `ActiveModelSerializers.config.key_transform`.

```ActiveModelSerializers.config.key_transform = :camel_lower```

##### Adapter default

Each adapter has a default transform configured:

| Adapter | Default Key Transform |
|----|----|
| `Json` | `:unaltered` |
| `JsonApi` | `:dash` |
