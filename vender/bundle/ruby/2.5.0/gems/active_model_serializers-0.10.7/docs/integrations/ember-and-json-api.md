[Back to Guides](../README.md)

# Integrating with Ember and JSON API

 - [Preparation](./ember-and-json-api.md#preparation)
 - [Server-Side Changes](./ember-and-json-api.md#server-side-changes)
 - [Adapter Changes](./ember-and-json-api.md#adapter-changes)
   - [Serializer Changes](./ember-and-json-api.md#serializer-changes)
 - [Including Nested Resources](./ember-and-json-api.md#including-nested-resources)

## Preparation

Note: This guide assumes that `ember-cli` is used for your ember app.

The JSON API specification calls for hyphens for multi-word separators. ActiveModelSerializers uses underscores.
To solve this, in Ember, both the adapter and the serializer will need some modifications:

### Server-Side Changes

First, set the adapter type in an initializer file:

```ruby
# config/initializers/active_model_serializers.rb
ActiveModelSerializers.config.adapter = :json_api
```

or:

```ruby
# config/initializers/active_model_serializers.rb
ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::JsonApi
```

You will also want to set the `key_transform` to `:unaltered` since you will adjust the attributes in your Ember serializer to use underscores instead of dashes later. You could also use `:underscore`, but `:unaltered` is better for performance.

```ruby
# config/initializers/active_model_serializers.rb
ActiveModelSerializers.config.key_transform = :unaltered
```

In order to properly handle JSON API responses, we need to register a JSON API renderer, like so:

```ruby
# config/initializers/active_model_serializers.rb
ActiveSupport.on_load(:action_controller) do
  require 'active_model_serializers/register_jsonapi_renderer'
end
```
Rails also requires your controller to tell it that you accept and generate JSONAPI data.  To do that, you use `respond_to` in your controller handlers to tell rails you are consuming and returning jsonapi format data. Without this, Rails will refuse to parse the request body into params.  You can add `ActionController::MimeResponds` to your application controller to enable this:

```ruby
class ApplicationController < ActionController::API
  include ActionController::MimeResponds
end
```
Then, in your controller you can tell rails you're accepting and rendering the jsonapi format:
```ruby
 # POST /post
  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.jsonapi { render jsonapi: @post, status: :created, location: @post }
      else
        format.jsonapi { render jsonapi: @post.errors, status: :unprocessable_entity }
      end
    end
  end
  
    # Only allow a trusted parameter "white list" through.
    def post_params
      ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: [:title, :body] )
    end
end
```

#### Note: 
In Rails 5, the "unsafe" method ( `jsonapi_parse!` vs the safe `jsonapi_parse`) throws an `InvalidDocument` exception when the payload does not meet basic criteria for JSON API deserialization.


### Adapter Changes

```javascript
// app/adapters/application.js
import Ember from 'ember';
import DS from 'ember-data';
import ENV from "../config/environment";
const { underscore, pluralize } = Ember.String;

export default  DS.JSONAPIAdapter.extend({
  namespace: 'api',
  // if your rails app is on a different port from your ember app
  // this can be helpful for development.
  // in production, the host for both rails and ember should be the same.
  host: ENV.host,

  // allows the multiword paths in urls to be underscored
  pathForType: function(type) {
    let underscored = underscore(type);
    return pluralize(underscored);
  },

});
```

### Serializer Changes

```javascript
// app/serializers/application.js
import Ember from 'ember';
import DS from 'ember-data';
var underscore = Ember.String.underscore;

export default DS.JSONAPISerializer.extend({
  keyForAttribute: function(attr) {
    return underscore(attr);
  },

  keyForRelationship: function(rawKey) {
    return underscore(rawKey);
  }
});

```


## Including Nested Resources

Ember Data can request related records by using `include`.  Below are some examples of how to make Ember Data request the inclusion of related records. For more on `include` usage, see: [The JSON API include examples](./../general/adapters.md#JSON-API)

```javascript
store.findRecord('post', postId, { include: 'comments' } );
```
which will generate the path /posts/{postId}?include='comments'

So then in your controller, you'll want to be sure to have something like:
```ruby
render jsonapi: @post, include: params[:include]
```

If you want to use `include` on a collection, you'd write something like this:

```javascript
store.query('post', { include: 'comments' });
```

which will generate the path `/posts?include='comments'`
