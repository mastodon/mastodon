# Docs - ActiveModel::Serializer 0.10.x

This is the documentation of ActiveModelSerializers, it's focused on the **0.10.x version.**

-----

## General

- [Getting Started](general/getting_started.md)
- [Configuration Options](general/configuration_options.md)
- [Serializers](general/serializers.md)
- [Adapters](general/adapters.md)
- [Rendering](general/rendering.md)
- [Caching](general/caching.md)
- [Logging](general/logging.md)
- [Deserialization](general/deserialization.md)
- [Instrumentation](general/instrumentation.md)
- JSON API
  - [Schema](jsonapi/schema.md)
  - [Errors](jsonapi/errors.md)

## How to

- [How to add root key](howto/add_root_key.md)
- [How to add pagination links](howto/add_pagination_links.md)
- [How to add relationship links](howto/add_relationship_links.md)
- [Using ActiveModelSerializers Outside Of Controllers](howto/outside_controller_use.md)
- [Testing ActiveModelSerializers](howto/test.md)
- [Passing Arbitrary Options](howto/passing_arbitrary_options.md)
- [How to serialize a Plain-Old Ruby Object (PORO)](howto/serialize_poro.md)
- [How to upgrade from `0.8` to `0.10` safely](howto/upgrade_from_0_8_to_0_10.md)

## Integrations

| Integration | Supported ActiveModelSerializers versions |  Gem name and/or link
|----|-----|----
| Ember.js | 0.9.x | [active-model-adapter](https://github.com/ember-data/active-model-adapter)
| Ember.js | 0.10.x + |  [docs/integrations/ember-and-json-api.md](integrations/ember-and-json-api.md)
| Grape | 0.10.x + | [docs/integrations/grape.md](integrations/grape.md)  |
| Grape | 0.9.x | https://github.com/jrhe/grape-active_model_serializers/ |
| Sinatra | 0.9.x | https://github.com/SauloSilva/sinatra-active-model-serializers/
