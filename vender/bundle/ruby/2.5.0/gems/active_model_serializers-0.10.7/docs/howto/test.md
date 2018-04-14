[Back to Guides](../README.md)

# How to test

## Controller Serializer Usage

ActiveModelSerializers provides a `assert_serializer` method to be used on your controller tests to
assert that a specific serializer was used.

```ruby
class PostsControllerTest < ActionController::TestCase
  test "should render post serializer" do
    get :index
    assert_serializer "PostSerializer"
  end
end
```

See [ActiveModelSerializers::Test::Serializer](../../lib/active_model_serializers/test/serializer.rb)
for more examples and documentation.

## Serialization against a schema

### Dependencies

To use the `assert_response_schema` you need to have the
[`json_schema`](https://github.com/brandur/json_schema) on your Gemfile. Please
add it to your Gemfile and run `$ bundle install`.

### Minitest test helpers

ActiveModelSerializers provides a `assert_response_schema` method to be used on your controller tests to
assert the response against a [JSON Schema](http://json-schema.org/). Let's take
a look in an example.

```ruby
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])

    render json: @post
  end
end
```

To test the `posts#show` response of this controller we need to create a file
named `test/support/schemas/posts/show.json`. The helper uses a naming convention
to locate the file.

This file is a JSON Schema representation of our response.

```json
{
  "properties": {
    "title" : { "type" : "string" },
    "content" : { "type" : "string" }
  }
}
```

With all in place we can go to our test and use the helper.

```ruby
class PostsControllerTest < ActionController::TestCase
  test "should render right response" do
    get :index
    assert_response_schema
  end
end
```

#### Load a custom schema

If we need to use another schema, for example when we have a namespaced API that
shows the same response, we can pass the path of the schema.

```ruby
module V1
  class PostsController < ApplicationController
    def show
      @post = Post.find(params[:id])

      render json: @post
    end
  end
end
```

```ruby
class V1::PostsControllerTest < ActionController::TestCase
  test "should render right response" do
    get :index
    assert_response_schema('posts/show.json')
  end
end
```

#### Change the schema path

By default all schemas are created at `test/support/schemas`. If we are using
RSpec for example we can change this to `spec/support/schemas` defining the
default schema path in an initializer.

```ruby
ActiveModelSerializers.config.schema_path = 'spec/support/schemas'
```

#### Using with the Heroku’s JSON Schema-based tools

To use the test helper with the [prmd](https://github.com/interagent/prmd) and
[committee](https://github.com/interagent/committee).

We need to change the schema path to the recommended by prmd:

```ruby
ActiveModelSerializers.config.schema_path = 'docs/schema/schemata'
```

We also need to structure our schemata according to Heroku's conventions
(e.g. including
[required metadata](https://github.com/interagent/prmd/blob/master/docs/schemata.md#meta-data)
and [links](https://github.com/interagent/prmd/blob/master/docs/schemata.md#links).

#### JSON Pointers

If we plan to use [JSON
Pointers](http://spacetelescope.github.io/understanding-json-schema/UnderstandingJSONSchema.pdf) we need to define the `id` attribute on the schema. Example:

```js
// attributes.json

{
  "id": "file://attributes.json#",
  "properties": {
    "name" : { "type" : "string" },
    "description" : { "type" : "string" }
  }
}
```

```js
// show.json

{
  "properties": {
    "name": {
      "$ref": "file://attributes.json#/properties/name"
    },
    "description": {
      "$ref": "file://attributes.json#/properties/description"
    }
  }
}
```
