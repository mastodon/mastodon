[Back to Guides](../README.md)

# Fields

If for any reason, you need to restrict the fields returned, you should use `fields` option.

For example, if you have a serializer like this

```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :access_token, :first_name, :last_name
end
```

and in a specific controller, you want to return `access_token` only, `fields` will help you:

```ruby
class AnonymousController < ApplicationController
  def create
    render json: User.create(activation_state: 'anonymous'), fields: [:access_token], status: 201
  end
end
```

Note that this is only valid for the `json` and `attributes` adapter. For the `json_api` adapter, you would use

```ruby
render json: @user, fields: { users: [:access_token] }
```

Where `users` is the JSONAPI type.
