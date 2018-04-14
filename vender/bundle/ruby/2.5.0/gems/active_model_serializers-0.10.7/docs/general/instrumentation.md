[Back to Guides](../README.md)

# Instrumentation

ActiveModelSerializers uses the
[ActiveSupport::Notification API](http://guides.rubyonrails.org/active_support_instrumentation.html#subscribing-to-an-event),
which allows for subscribing to events, such as for logging.

## Events

Name:

`render.active_model_serializers`

Payload (example):

```ruby
{
  serializer: PostSerializer,
  adapter: ActiveModelSerializers::Adapter::Attributes
}
```

Subscribing:

```ruby
ActiveSupport::Notifications.subscribe 'render.active_model_serializers' do |name, started, finished, unique_id, data|
  # whatever
end
ActiveSupport::Notifications.subscribe 'render.active_model_serializers' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  # event.payload
  # whatever
end
```

## [LogSubscriber](http://api.rubyonrails.org/classes/ActiveSupport/LogSubscriber.html)

ActiveModelSerializers includes an `ActiveModelSerializers::LogSubscriber` that attaches to
`render.active_model_serializers`.
