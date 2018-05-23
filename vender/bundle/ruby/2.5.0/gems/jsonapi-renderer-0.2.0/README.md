# jsonapi-renderer
Ruby gem for rendering [JSON API](http://jsonapi.org) documents.

## Status

[![Gem Version](https://badge.fury.io/rb/jsonapi-renderer.svg)](https://badge.fury.io/rb/jsonapi-renderer)
[![Build Status](https://secure.travis-ci.org/jsonapi-rb/jsonapi-renderer.svg?branch=master)](http://travis-ci.org/jsonapi-rb/renderer?branch=master)
[![codecov](https://codecov.io/gh/jsonapi-rb/jsonapi-renderer/branch/master/graph/badge.svg)](https://codecov.io/gh/jsonapi-rb/renderer)
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/jsonapi-rb/Lobby)

## Resources

* Chat: [gitter](http://gitter.im/jsonapi-rb)
* Twitter: [@jsonapirb](http://twitter.com/jsonapirb)
* Docs: [jsonapi-rb.org](http://jsonapi-rb.org)

## Installation
```ruby
# In Gemfile
gem 'jsonapi-renderer'
```
then
```
$ bundle
```
or manually via
```
$ gem install jsonapi-renderer
```

## Usage

First, require the gem:
```ruby
require 'jsonapi/renderer'
```

### Rendering resources

A resource here is any class that implements the following interface:
```ruby
class ResourceInterface
  # Returns the type of the resource.
  # @return [String]
  def jsonapi_type; end

  # Returns the id of the resource.
  # @return [String]
  def jsonapi_id; end

  # Returns a hash containing, for each included relationship, an array of the
  # resources to be included from that one.
  # @param included_relationships [Array<Symbol>] The keys of the relationships
  #   to be included.
  # @return [Hash{Symbol => Array<#ResourceInterface>}]
  def jsonapi_related(included_relationships); end

  # Returns a JSON API-compliant representation of the resource as a hash.
  # @param options [Hash]
  #   @option fields [Set<Symbol>, Nil] The requested fields, or nil.
  #   @option include [Set<Symbol>] The requested relationships to
  #     include (defaults to []).
  # @return [Hash]
  def as_jsonapi(options = {}); end
end
```

#### Rendering a single resource
```ruby
JSONAPI.render(data: resource,
               include: include_string,
               fields: fields_hash,
               meta: meta_hash,
               links: links_hash)
```

This returns a JSON API compliant hash representing the described document.

#### Rendering a collection of resources
```ruby
JSONAPI.render(data: resources,
               include: include_string,
               fields: fields_hash,
               meta: meta_hash,
               links: links_hash)
```

This returns a JSON API compliant hash representing the described document.

#### Rendering a relationship
```ruby
JSONAPI.render(data: resource,
               relationship: :posts,
               include: include_string,
               fields: fields_hash,
               meta: meta_hash,
               links: links_hash)
```

This returns a JSON API compliant hash representing the described document.

### Rendering errors

```ruby
JSONAPI.render_errors(errors: errors,
                      meta: meta_hash,
                      links: links_hash)
```

where `errors` is an array of objects implementing the `as_jsonapi` method, that
returns a JSON API-compliant representation of the error.

This returns a JSON API compliant hash representing the described document.

### Caching

The generated JSON fragments can be cached in any cache implementation
supporting the `fetch_multi` method.

When using caching, the serializable resources must implement an
additional `jsonapi_cache_key` method:
```ruby
  # Returns a cache key for the resource, parametered by the `include` and
  #   `fields` options.
  # @param options [Hash]
  #   @option fields [Set<Symbol>, Nil] The requested fields, or nil.
  #   @option include [Set<Symbol>] The requested relationships to
  #     include (defaults to []).
  # @return [String]
  def jsonapi_cache_key(options = {}); end
```

The cache instance must be passed to the renderer as follows:
```ruby
JSONAPI.render(data: resources,
               include: include_string,
               fields: fields_hash,
               cache: cache_instance)
```

## License

jsonapi-renderer is released under the [MIT License](http://www.opensource.org/licenses/MIT).
