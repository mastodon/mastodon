[Back to Guides](../README.md)

# Passing Arbitrary Options To A Serializer

In addition to the [`serialization_scope`](../general/serializers.md#scope), any options passed to `render`
that are not reserved for the [adapter](../general/rendering.md#adapter_opts)
are available in the serializer as [instance_options](../general/serializers.md#instance_options).

For example, we could pass in a field, such as `user_id` into our serializer.

```ruby
# posts_controller.rb
class PostsController < ApplicationController
  def dashboard
    render json: @post, user_id: 12
  end
end

# post_serializer.rb
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  def comments_by_me
    Comments.where(user_id: instance_options[:user_id], post_id: object.id)
  end
end
```
