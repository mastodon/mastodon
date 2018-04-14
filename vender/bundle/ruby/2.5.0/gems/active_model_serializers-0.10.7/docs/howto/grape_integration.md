[Back to Guides](../README.md)

The ActiveModelSerializers grape formatter relies on the existence of `env['grape.request']` which is implemeted by `Grape::Middleware::Globals`. You can meet his dependency by calling it before mounting the endpoints.

In the simpliest way:

```
class API < Grape::API
  # @note Make sure this is above you're first +mount+
  use Grape::Middleware::Globals
end
```

or more like what is shown in current Grape tutorials:

```
module MyApi
  class ApiBase < Grape::API
    use Grape::Middleware::Globals

    require 'grape/active_model_serializers'
    include Grape::ActiveModelSerializers

    mount MyApi::V1::ApiBase
  end
end
```

You could meet this dependency with your own middleware. The invocation might look like:

```
module MyApi
  class ApiBase < Grape::API
    use My::Middleware::Thingamabob

    require 'grape/active_model_serializers'
    include Grape::ActiveModelSerializers

    mount MyApi::V1::ApiBase
  end
end
```
