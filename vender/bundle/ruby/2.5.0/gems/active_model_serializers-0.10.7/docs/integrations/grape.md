# Integration with Grape

[Grape](https://github.com/ruby-grape/grape) is an opinionated micro-framework for creating REST-like APIs in ruby.

ActiveModelSerializers currently supports Grape >= 0.13, < 1.0

To add [Grape](https://github.com/ruby-grape/grape) support, enable the formatter and helper functions by including `Grape::ActiveModelSerializers` in your base endpoint. For example:

```ruby
module Example
  class Dummy < Grape::API
    require 'grape/active_model_serializers'
    include Grape::ActiveModelSerializers
    mount Example::V1::Base
  end
end
```

Aside from this, [configuration](../general/configuration_options.md) of ActiveModelSerializers is exactly the same.
