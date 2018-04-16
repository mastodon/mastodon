# master

# Version 5.0.0

## Breaking changes

  * Try to align the gem version with the ElasticSearch version we support

  * `Chewy.default_field_type` is `text` now.

  * `Chewy::Stash` was split onto two indexes - `Chewy::Stash::Specification` and `Chewy::Stash::Journal`

  * Data for journal and specification is stored in binary fields base64-encoded to bypass the limits of other fields.

  * Don't underscore suggested index name (@dm1try, #626)

## Changes

  * `pipeline` import option support (@eManPrague, #598)

  * Proper Rails check (@nattfodd, #625)

  * Bypass strategy performance improvements (@DNNX, #623)

  * Avoid index update calls for empty data (@robertasg, #620)

  * Do not underscore suggested index name on `Chewy::Index.index_name` call.

  * It is possible now to call `root` method several times inside a single type definition, the options will be merged. Also, the block isn't required anymore.

  * Fixed some Sequel deprecation warnings (@arturtr - #565, @matchbookmac - #577)

## Bugfixes

  * Fixed index settings logic error (@yahooguntu, #593)

  * Missed check in higlight method (@heartfulbird, #567)

# Version 0.10.1

## Changes

  * Improved parallel worker titles (#558)

## Bugfixes

  * Fixed request strategy initial debug message (#557)

  * Fixed will objects paginated array initialization when pagination was not used (#556)

  * Fixed fields symbol/string value (#555)

  * Fixed root field value proc (#554)

# Version 0.10.0

## Breaking changes

  * Changed behavior of `Chewy::Index.index_name`, it doesn't cache the values anymore.

  * Journal interfaces, related code and rake tasks were completely refactored and are not compatible with the previous version.

## Changes

  * Less noisy strategies logging (@Borzik, #543)

  * Parallel import and the corresponding rake tasks.

  * `:shoryuken` async strategy (@josephchoe, #532)

  * Deprecate `Chewy::Index.build_index_name`.

  * Rename `Chewy::Index.default_prefix` to `Chewy::Index.prefix`. The old one is deprecated.

  * Add `Chewy::Type.derivable_name` for consistency.

  * Rename `Chewy::Index.derivable_index_name` to `Chewy::Index.derivable_name`.
    `Chewy::Index.derivable_index_name` and `Chewy::Type.derivable_index_name` are deprecated.

  * Use normal YAML loading, for the config, we don't need the safe one.

  * `default_root_options` option (@barthez, #526)

  * Partial indexing ability: it is possible to update only specified fields.

  * New cool `rake chewy:deploy` task.

  * Selective reset (resets only if necessary): `rake chewy:upgrade`.

  * Consistency checks and synchronization: `rake chewy:sync`.

  * Brand new request DSL. Supports ElasticSearch 2 and 5, better usability, architecture and docs.

  * Add Kaminari 1.0 support.

  * `skip_index_creation_on_import` option (@sergey-kintsel, #483)

  * Ability to use procs for settings (@parallel588, #481)

  * Bulk indexing optimizations with new additional options (@eproulx-petalmd, #467)

  * Configurable sidekiq options (@averell23, #438)

# Version 0.9.0

## Changes

  * Add `preference` param to Query (@menglewis, #443)

  * Add the `track_scores` option to the query; `_score` to be computed and tracked even when there are no `_score` in sort. (@dmitry, #417)

  * Confugurable `Chewy.indices_path` (@robacarp, #414, #433, #439)

  * [Journaling](https://github.com/toptal/chewy/#journaling) implementation (@sergey-kintsel, #409, #425, #428, #432, #434, #463)

  * Minitest helpers (@robacarp, #396)

  * `Chewy::Query#unlimited` to fetch all the documents (@sergey-kintsel, #393)

  * `Chewy::Query#exists?` (@sergey-kintsel, #386)

  * Import otimizations (#381, #376)

  * Additional import optimization technique - [raw import](https://github.com/toptal/chewy/#raw-import) (@DNNX, #375)

  * `weight` scoring dunction was added to the search DSL (@sevab, #380)

  * Rake tasks support multiple indexes and exceptions: `rake chewy:reset[users,projects]`, `rake chewy:update[-projects]`

  * Witchcraft™ supports dynamically generated procs with variables from closure.

  * Added `Query#preference` for specifying shard replicas to query against. (@menglewis)

## Bugfixes

  * `.script_fields` method in the Index class (@dmitry, #415)

  * Fix routing_missing_exception on delete with parent missing (@guigs, #398)

  * Sequesl custom primary keys handling fix (@okliv, #385)

  * Bulk import fixes (@0x0badc0de, #374)

# Version 0.8.4

## Changes

  * Brand new import `:bulk_size` option, set desired ElasticSearch bulk size in bytes

  * Witchcraft™ technology

  * Configurable per-type default import options (@barthez, #341)

  * Various codebase optimizations (@DNNX, @pyromaniac)

  * `update_index` Rspec matcher messages improvements

  * `:all` rake tasks deprecation

  * Scoped notification subscriptions in rake tasks (@0x0badc0de, #335)

  * Async strategies workers accept options (@dnd, #321)

  * Prefix is configurable per-index (@mikeyhogarth, #314)

  * Ability to pass proc for transport configuration (@feymartynov, @reidab, #302, #339)

  * ElasticSearch 2 support (@sergeygaychuk, #297)

  * Accessing types with methods is deprecated. Use `MyIndex::MyType` constant reference instead of `MyIndex.my_type` method.

  * Sequel adapter improvements (@mrbrdo, #294)

## Bugfixes

  * Mongoid atomic strategy fix (#325)

  * Method missing fix (@jesjos, #324)

  * Hash fields composition fix (@eproulx-petalmd, #319)

  * Better errors handling in strategies (@barthez, #306)

  * Assets strategies silencer fix for Rails 5 API mode (@clupprich, #303)

# Version 0.8.3

## Breaking changes:

  * `Chewy.atomic` and `Chewy.urgent_update=` methods was removed from the codebase, use `Chewy.strategy` block instead.

  * `delete_from_index?` hook is removed from the codebase.

## Changes

  * Sequel support completely reworked to use common ORM implementations + better sequel specs covarage.

## Bugfixes

  * Sequel objects transactional destruction fix

  * Correct Rspec mocking framework checking (@mainameiz)

  * Atomic strategy is now compatible with custom ids proc.

  * Safe unsubscribe on import (@marshall-lee)

  * Correct custom assets path silencer (@davekaro)

# Version 0.8.2

## Changes

  * ActiveJob strategy by @mkcode

  * Async strategies tweak (@AndreySavelyev)

  * GeoPoint readme (@joonty)

  * Multiple grammar fixes and code improvements (@biow0lf)

  * Named aggregations by @caldwecr

  * Sequel adapter by @jirutka

  * Rake helper methods extracted (@caldwecr, @jirutka)

  * Multiple grammar fixes (@henrebotha)

  * Ability to pass a proc to `update_index` to define updating index dynamically (@SeTeM)


## Bugfixes

  * Fixed transport logger and tracer configuration

# Version 0.8.1

## Bugfixes

  * Added support of elasticsearch-ruby 1.0.10

# Version 0.8.0

## Breaking changes:

  * `:atomic` and `:urgent` strategies are using `import!` method raising exceptions

## Changes

  * Crutches™ technology

  * Added `.script_fields` chainable method to query (@ka8725)

  * `update_index` matcher mocha support (@lardawge)

  * `:resque` async strategy

  * `:sidekiq` async strategy (inspired by @sharkzp)

  * Added `Query#search_type` for `search_type` request option setup (@marshall-lee)

## Bugfixes

  * Rails 4.2 migrations are not raising UndefinedUpdateStrategy anymore on data updates

  * Mongoid random failing specs fixes (@marshall-lee)

# Version 0.7.0

## Breaking changes:

  * `Chewy.use_after_commit_callbacks = false` returns previous RDBMS behavior
  in tests

  * ActiveRecord import is now called after_commit instead of after_save and after_destroy

  * Import now respects default scope and removes unmatched documents

  * `delete_from_index?` method is deprecated, use

    ```ruby
      define_type User, delete_if: ->{ removed? } do
        ...
      end
    ```

  * `Chewy.request_strategy` to configure action controller's request wrapping strategy

  * `Chewy.root_strategy` to configure the first strategy in stack

  * Default strategy for controller actions is `:atomic`

  * Default strategy for activerecord migrations is `:bypass`

  * Default strategy for sandbox console is `:bypass`

  * Default strategy for rails console is `:urgent`

  * `Chewy.configuration` was renamed to `Chewy.settings`

  * Reworked index update strategies implementation. `Chewy.atomic`
  and `Chewy.urgent_update` are now deprecated in favour of the new
  `Chewy.strategy` API.

  * Loading objects for object-sourced types using `wrap` method is
  deprecated, `load_one` method should be used instead. Or method name
  might be passed to `define_type`:

    ```ruby
      class GeoData
        def self.get_data(elasticsearch_document)
          REDIS.get("geo_data_#{elasticsearch_document.id}")
        end
      end

      ...
        define_type GeoData, load_one_method: :get_data do
          ...
        end
    ```

## Changes

  * Multiple enhancements by @DNNX

  * Added `script_fields` to search criteria (@ka8725)

  * ORM adapters now completely relies on the default scope. This means every scope or objects passed to import are merged with default scope so basically there is no need to define `delete_if` block. Default scope strongly restricts objects which may land in the current index.

    ```ruby
      define_type Country.where("rating > 30") do

      end

      # this code would import only countries with rating between 30 and 50
      CountriesIndex::Country.import(Country.where("rating < 50"))

      # the same is true for arrays of objects or ids
      CountriesIndex::Country.import(Country.where("rating < 50").to_a)
      CountriesIndex::Country.import(Country.where("rating < 50").pluck(:id))
    ```

  * Object adapter supports custom initial import and load methods, so it
  could be configured to be used with procs or any class responding to `call`
  method.

    ```ruby
      class GeoData
        def self.call
          REDIS.get_all
        end
      end

      ...
        define_type GeoData do
          ...
        end
    ```

  * Nested fields value procs additional arguments: parent objects.

    ```ruby
      define_type Country do
        field :name
        field :cities do
          field :district, value: ->(city, country) { city.districts if country.main? }
        end
      end
    ```

  * Implemented basic named scopes

## Bugfixes

  * `script_score` allow options (@joeljunstrom)

  * Chewy indexes eaged loading fixes (@leemhenson)

  * `Chewy::Index.import nil` imports nothing instead of initial data

# Version 0.6.2

## Changes

  * document root id custom value option (@baronworks)

## Bugfixes

  * Removed decay function defaults (@Linuus)

  * Correct config file handling in case of empty file

# Version 0.6.1

## Changes

  * `min_score` query option support (@jshirley)

  * `Chewy::Query#find` method for finding documents by id

# Version 0.6.0

## Changes

  * Mongoid support YaY! (@fabiotomio, @leemhenson)

  * `urgent: true` option for `update_index` is deprecated and will be removed soon, use `Chewy.atomic` instead

  * `timeout` and `timed_out` support (@MarkMurphy)

  * will_paginate support (@josecoelho)

## Bugfixes

  * All the query chainable methods delegated to indexes and types (partially @Linuus)

# Version 0.5.2

## Breaking changes:

  * `Chewy::Type::Base` removed in favour of using `Chewy::Type` as a base class for all types

## Changes

  * `Chewy.massacre` aliased to `Chewy.delete_all` method deletes all the indexes with current prefix

## Bugfixes:

  * Advanced type classes resolving (@inbeom)

  * `import` ignores nil

# Version 0.5.1

## Changes:

  * `chewy.yml` Rails generator (@jirikolarik)

  * Parent-child mappings feature support (@inbeom)

  * `Chewy::Index.total_count` and `Chewy::Type::Base.total_count`

  * `Chewy::Type::Base.reset` method. Deletes all the type documents and performs import (@jondavidford)

  * Added `Chewy::Query#delete_all` scope method using delete by query ES feature (@jondavidford)

  * Rspec 3 `update_index` matcher support (@jimmybaker)

  * Implemented function scoring (@averell23)

## Bugfixes:

  * Indexed eager-loading fix (@leemhenson)

  * Field type deriving nested type support fix (@rschellhorn)

# Version 0.5.0

## Breaking changes:

  * 404 exception (IndexMissingException) while query is swallowed and treated like an empty result set.

  * `load` and `preload` for queries became lazy. Might be partially incompatible.

  * Changed mapping behavior: multi-fields are defined in conformity with ElasticSearch documentation (http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/_multi_fields.html#_multi_fields)

## Changes:

  * `suggest` query options support (@rschellhorn).

  * Added hash data support. How it is possible to pass hashes to import.

  * `rake chewy:reset` and `rake chewy:update` paramless acts as `rake chewy:reset:all` and `rake chewy:update:all` respectively

  * Added `delete_from_index?` API method for custom deleted objects marking.

  * Added `post_filter` API, working the same way as filters.

  * Added chainable `strategy` query method.

  * Aliasing is performed in index create request for ElasticSearch >= 1.1.

  * `preload` scope method loads ORM/ODM objects in background.

  * `load` method `:only` and `:except` options to specify load types.

  * `highlight` and `rescore` query options support.

  * config/chewy.yml ERB support.

## Bugfixes:

  * Fixed `missing` and `exists` filters DSL constructors.

  * Reworked index data composing.

  * Support for Kaminari new PaginatableArray behavior (@leemhenson)

  * Correct waiting for status. After index creation, bulk import, and deletion.

  * Fix #23 "wrong constant name" with namespace models

# Version 0.4.0

  * Changed `update_index` matcher behavior. Now it compare array attributes position-independently.

  * Search aggregations API support (@arion).

  * Chewy::Query#facets called without params performs the request and returns facets.

  * Added `Type.template` DSL method for root objects dynamic templates definition. See [mapping.rb](lib/chewy/type/mapping.rb) for more details.

  * ActiveRecord adapter custom `primary_key` support (@matthee).

  * Urgent update now clears association cache in ActiveRecord to ensure latest changes are imported.

  * `import` now creates index before performing.

  * `Chewy.configuration[:wait_for_status]` option. Can be set to `red`, `yellow` or `green`. If set - chewy will wait for cluster status before creating, deleting index and import. Useful for specs.

# Version 0.3.0

  * Added `Chewy.configuration[:index]` config to setup common indexes options.

  * `Chewy.client_options` replaced with `Chewy.configuration`

  * Using source filtering instead of fields filter (http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-source-filtering.html).

# Version 0.2.3

  * `.import!` indexes method, raises import errors.

  * `.import!` types method, raises import errors. Useful for specs.

# Version 0.2.2

  * Support for `none` scope (@undr).

  * Auto-resolved analyzers and analyzers repository (@webgago):

    ```ruby
      # Setting up analyzers repository:
      Chewy.analyzer :title_analyzer, type: 'custom', filter: %w(lowercase icu_folding title_nysiis)
      Chewy.filter :title_nysiis, type: 'phonetic', encoder: 'nysiis', replace: false

      # Using analyzers from repository in index classes
      class ProductsIndex < Chewy::Index
        settings analysis: {analyzer: ['title_analyzer', {one_more_analyzer: {type: 'custom', tokenizer: 'lowercase'}}]}
      end
    ```

    `title_analyzer` here will be automatically resolved and passed to index mapping

# Version 0.2.0

  * Reworked import error handling. Now all the import errors from ElasticSearch are handled properly, also import method returns true of false depending on the import process success.

  * `Chewy::Index.import` now takes types hash as argument within options hash:

    `PlacesIndex.import city: City.enabled, country: Country.enabled, refresh: false`

  * Old indexes cleanup after reset.

  * Added index prefixes.

  * `define_type` now takes options for adapter.

  * `chewy:reset` and `chewy:reset:all` rake tasks are now trying to reset index with zero downtime if it is possible.

  * Added `chewy:update:all` rake task.

  * Methods `.create`, `.create!`, `.delete`, `.delete`, `reset!` are now supports index name suffix passing as the first argument. See [actions.rb](lib/chewy/index/actions.rb) for more details.

  * Method `reset` renamed to `reset!`.

  * Added common loading scope for AR adapter. Also removed scope proc argument, now it executes just in main load scope context.

    `CitiesIndex.all.load(scope: {city: City.include(:country)})`
    `CitiesIndex.all.load(scope: {city: -> { include(:country) }})`
    `CitiesIndex.all.load(scope: ->{ include(:country) })`

# Version 0.1.0

  * Added filters simplified DSL. See [filters.rb](lib/chewy/query/filters.rb) for more details.

  * Queries and filters join system reworked. See [query.rb](lib/chewy/query.rb) for more details.

  * Added query `merge` method

  * `update_index` matcher now wraps expected block in `Chewy.atomic` by default.
    This behaviour can be prevented with `atomic: false` option passing

    ```ruby
      expect { user.save! }.to update_index('users#user', atomic: false)
    ```

  * Renamed `Chewy.observing_enabled` to `Chewy.urgent_update` with `false` as default

  * `update_elasticsearch` renamed to `update_index`, added `update_index`
    `:urgent` option

  * Added import ActiveSupport::Notifications instrumentation
    `ActiveSupport::Notifications.subscribe('import_objects.chewy') { |*args| }`

  * Added `types!` and `only!` query chain methods, which purges previously
    chained types and fields

  * `types` chain method now uses types filter

  * Added `types` query chain method

  * Changed types access API:

    ```ruby
      UsersIndex::User # => UsersIndex::User
      UsersIndex::types_hash['user'] # => UsersIndex::User
      UsersIndex.user # => UsersIndex::User
      UsersIndex.types # => [UsersIndex::User]
      UsersIndex.type_names # => ['user']
    ```

  * `update_elasticsearch` method name as the second argument

    ```ruby
      update_elasticsearch('users#user', :self)
      update_elasticsearch('users#user', :users)
    ```

  * Changed index handle methods, removed `index_` prefix. I.e. was
    `UsersIndex.index_create`, became `UsersIndex.create`

  * Ability to pass value proc for source object context if arity == 0
    `field :full_name, value: ->{ first_name + last_name }` instead of
    `field :full_name, value: ->(u){ u.first_name + u.last_name }`

  * Added `.only` chain to `update_index` matcher

  * Added ability to pass ActiveRecord::Relation as a scope for load
    `CitiesIndex.all.load(scope: {city: City.include(:country)})`

  * Added method `all` to index for query DSL consistency

  * Implemented isolated adapters to simplify adding new ORMs

  * Query DLS chainable methods delegated to index class
    (no longer need to call MyIndex.search.query, just MyIndex.query)

# Version 0.0.1

  * Query DSL

  * Basic index handling

  * Initial version
