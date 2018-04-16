# Previous DSL readme.

See `Chewy::Query` for details.

* [Index querying](#index-querying)
* [Additional query action.](#additional-query-action)
* [Filters query DSL](#filters-query-dsl)
* [Faceting](#faceting)
* [Aggregations](#aggregations)
* [Script fields](#script-fields)
* [Script scoring](#script-scoring)
* [Boost Factor](#boost-factor)
* [Objects loading](#objects-loading)

## Index querying

```ruby
scope = UsersIndex.query(term: {name: 'foo'})
  .filter(range: {rating: {gte: 100}})
  .order(created: :desc)
  .limit(20).offset(100)

scope.to_a # => will produce array of UserIndex::User or other types instances
scope.map { |user| user.email }
scope.total_count # => will return total objects count

scope.per(10).page(3) # supports kaminari pagination
scope.explain.map { |user| user._explanation }
scope.only(:id, :email) # returns ids and emails only

scope.merge(other_scope) # queries could be merged
```

Also, queries can be performed on a type individually:

```ruby
UsersIndex::User.filter(term: {name: 'foo'}) # will return UserIndex::User collection only
```

If you are performing more than one `filter` or `query` in the chain, all the filters and queries will be concatenated in the way specified by
`filter_mode` and `query_mode` respectively.

The default `filter_mode` is `:and` and the default `query_mode` is `bool`.

Available filter modes are: `:and`, `:or`, `:must`, `:should` and any minimum_should_match-acceptable value

Available query modes are: `:must`, `:should`, `:dis_max`, any minimum_should_match-acceptable value or float value for dis_max query with tie_breaker specified.

```ruby
UsersIndex::User.filter{ name == 'Fred' }.filter{ age < 42 } # will be wrapped with `and` filter
UsersIndex::User.filter{ name == 'Fred' }.filter{ age < 42 }.filter_mode(:should) # will be wrapped with bool `should` filter
UsersIndex::User.filter{ name == 'Fred' }.filter{ age < 42 }.filter_mode('75%') # will be wrapped with bool `should` filter with `minimum_should_match: '75%'`
```

See [query.rb](lib/chewy/query.rb) for more details.

## Additional query action.

You may also perform additional actions on the query scope, such as deleting of all the scope documents:

```ruby
UsersIndex.delete_all
UsersIndex::User.delete_all
UsersIndex.filter{ age < 42 }.delete_all
UsersIndex::User.filter{ age < 42 }.delete_all
```

## Filters query DSL

There is a test version of the filter-creating DSL:

```ruby
UsersIndex.filter{ name == 'Fred' } # will produce `term` filter.
UsersIndex.filter{ age <= 42 } # will produce `range` filter.
```

The basis of the DSL is the expression. There are 2 types of expressions:

* Simple function

  ```ruby
  UsersIndex.filter{ s('doc["num"] > 1') } # script expression
  UsersIndex.filter{ q(query_string: {query: 'lazy fox'}) } # query expression
  ```

* Field-dependent composite expression
  Consists of the field name (with or without dot notation), a value, and an action operator between them. The field name might take additional options for passing to the resulting expression.

  ```ruby
  UsersIndex.filter{ name == 'Name' } # simple field term filter
  UsersIndex.filter{ name(:bool) == ['Name1', 'Name2'] } # terms query with `execution: :bool` option passed
  UsersIndex.filter{ answers.title =~ /regexp/ } # regexp filter for `answers.title` field
  ```

You can combine expressions as you wish with the help of combination operators.

```ruby
UsersIndex.filter{ (name == 'Name') & (email == 'Email') } # combination produces `and` filter
UsersIndex.filter{
  must(
    should(name =~ 'Fr').should_not(name == 'Fred') & (age == 42), email =~ /gmail\.com/
  ) | ((roles.admin == true) & name?)
} # many of the combination possibilities
```

There is also a special syntax for cache enabling:

```ruby
UsersIndex.filter{ ~name == 'Name' } # you can apply tilde to the field name
UsersIndex.filter{ ~(name == 'Name') } # or to the whole expression

# if you are applying cache to the one part of range filter
# the whole filter will be cached:
UsersIndex.filter{ ~(age > 42) & (age <= 50) }

# You can pass cache options as a field option also.
UsersIndex.filter{ name(cache: true) == 'Name' }
UsersIndex.filter{ name(cache: false) == 'Name' }

# With regexp filter you can pass _cache_key
UsersIndex.filter{ name(cache: 'name_regexp') =~ /Name/ }
# Or not
UsersIndex.filter{ name(cache: true) =~ /Name/ }
```

Compliance cheatsheet for filters and DSL expressions:

* Term filter

  ```json
  {"term": {"name": "Fred"}}
  {"not": {"term": {"name": "Johny"}}}
  ```

  ```ruby
  UsersIndex.filter{ name == 'Fred' }
  UsersIndex.filter{ name != 'Johny' }
  ```

* Terms filter

  ```json
  {"terms": {"name": ["Fred", "Johny"]}}
  {"not": {"terms": {"name": ["Fred", "Johny"]}}}

  {"terms": {"name": ["Fred", "Johny"], "execution": "or"}}

  {"terms": {"name": ["Fred", "Johny"], "execution": "and"}}

  {"terms": {"name": ["Fred", "Johny"], "execution": "bool"}}

  {"terms": {"name": ["Fred", "Johny"], "execution": "fielddata"}}
  ```

  ```ruby
  UsersIndex.filter{ name == ['Fred', 'Johny'] }
  UsersIndex.filter{ name != ['Fred', 'Johny'] }

  UsersIndex.filter{ name(:|) == ['Fred', 'Johny'] }
  UsersIndex.filter{ name(:or) == ['Fred', 'Johny'] }
  UsersIndex.filter{ name(execution: :or) == ['Fred', 'Johny'] }

  UsersIndex.filter{ name(:&) == ['Fred', 'Johny'] }
  UsersIndex.filter{ name(:and) == ['Fred', 'Johny'] }
  UsersIndex.filter{ name(execution: :and) == ['Fred', 'Johny'] }

  UsersIndex.filter{ name(:b) == ['Fred', 'Johny'] }
  UsersIndex.filter{ name(:bool) == ['Fred', 'Johny'] }
  UsersIndex.filter{ name(execution: :bool) == ['Fred', 'Johny'] }

  UsersIndex.filter{ name(:f) == ['Fred', 'Johny'] }
  UsersIndex.filter{ name(:fielddata) == ['Fred', 'Johny'] }
  UsersIndex.filter{ name(execution: :fielddata) == ['Fred', 'Johny'] }
  ```

* Regexp filter (== and =~ are equivalent)

  ```json
  {"regexp": {"name.first": "s.*y"}}

  {"not": {"regexp": {"name.first": "s.*y"}}}

  {"regexp": {"name.first": {"value": "s.*y", "flags": "ANYSTRING|INTERSECTION"}}}
  ```

  ```ruby
  UsersIndex.filter{ name.first == /s.*y/ }
  UsersIndex.filter{ name.first =~ /s.*y/ }

  UsersIndex.filter{ name.first != /s.*y/ }
  UsersIndex.filter{ name.first !~ /s.*y/ }

  UsersIndex.filter{ name.first(:anystring, :intersection) == /s.*y/ }
  UsersIndex.filter{ name.first(flags: [:anystring, :intersection]) == /s.*y/ }
  ```

* Prefix filter

  ```json
  {"prefix": {"name": "Fre"}}
  {"not": {"prefix": {"name": "Joh"}}}
  ```

  ```ruby
  UsersIndex.filter{ name =~ re' }
  UsersIndex.filter{ name !~ 'Joh' }
  ```

* Exists filter

  ```json
  {"exists": {"field": "name"}}
  ```

  ```ruby
  UsersIndex.filter{ name? }
  UsersIndex.filter{ !!name }
  UsersIndex.filter{ !!name? }
  UsersIndex.filter{ name != nil }
  UsersIndex.filter{ !(name == nil) }
  ```

* Missing filter

  ```json
  {"missing": {"field": "name", "existence": true, "null_value": false}}
  {"missing": {"field": "name", "existence": true, "null_value": true}}
  {"missing": {"field": "name", "existence": false, "null_value": true}}
  ```

  ```ruby
  UsersIndex.filter{ !name }
  UsersIndex.filter{ !name? }
  UsersIndex.filter{ name == nil }
  ```

* Range

  ```json
  {"range": {"age": {"gt": 42}}}
  {"range": {"age": {"gte": 42}}}
  {"range": {"age": {"lt": 42}}}
  {"range": {"age": {"lte": 42}}}

  {"range": {"age": {"gt": 40, "lt": 50}}}
  {"range": {"age": {"gte": 40, "lte": 50}}}

  {"range": {"age": {"gt": 40, "lte": 50}}}
  {"range": {"age": {"gte": 40, "lt": 50}}}
  ```

  ```ruby
  UsersIndex.filter{ age > 42 }
  UsersIndex.filter{ age >= 42 }
  UsersIndex.filter{ age < 42 }
  UsersIndex.filter{ age <= 42 }

  UsersIndex.filter{ age == (40..50) }
  UsersIndex.filter{ (age > 40) & (age < 50) }
  UsersIndex.filter{ age == [40..50] }
  UsersIndex.filter{ (age >= 40) & (age <= 50) }

  UsersIndex.filter{ (age > 40) & (age <= 50) }
  UsersIndex.filter{ (age >= 40) & (age < 50) }
  ```

* Bool filter

  ```json
  {"bool": {
    "must": [{"term": {"name": "Name"}}],
    "should": [{"term": {"age": 42}}, {"term": {"age": 45}}]
  }}
  ```

  ```ruby
  UsersIndex.filter{ must(name == 'Name').should(age == 42, age == 45) }
  ```

* And filter

  ```json
  {"and": [{"term": {"name": "Name"}}, {"range": {"age": {"lt": 42}}}]}
  ```

  ```ruby
  UsersIndex.filter{ (name == 'Name') & (age < 42) }
  ```

* Or filter

  ```json
  {"or": [{"term": {"name": "Name"}}, {"range": {"age": {"lt": 42}}}]}
  ```

  ```ruby
  UsersIndex.filter{ (name == 'Name') | (age < 42) }
  ```

  ```json
  {"not": {"term": {"name": "Name"}}}
  {"not": {"range": {"age": {"lt": 42}}}}
  ```

  ```ruby
  UsersIndex.filter{ !(name == 'Name') } # or UsersIndex.filter{ name != 'Name' }
  UsersIndex.filter{ !(age < 42) }
  ```

* Match all filter

  ```json
  {"match_all": {}}
  ```

  ```ruby
  UsersIndex.filter{ match_all }
  ```

* Has child filter

  ```json
  {"has_child": {"type": "blog_tag", "query": {"term": {"tag": "something"}}}
  {"has_child": {"type": "comment", "filter": {"term": {"user": "john"}}}
  ```

  ```ruby
  UsersIndex.filter{ has_child(:blog_tag).query(term: {tag: 'something'}) }
  UsersIndex.filter{ has_child(:comment).filter{ user == 'john' } }
  ```

* Has parent filter

  ```json
  {"has_parent": {"type": "blog", "query": {"term": {"tag": "something"}}}}
  {"has_parent": {"type": "blog", "filter": {"term": {"text": "bonsai three"}}}}
  ```

  ```ruby
  UsersIndex.filter{ has_parent(:blog).query(term: {tag: 'something'}) }
  UsersIndex.filter{ has_parent(:blog).filter{ text == 'bonsai three' } }
  ```

See [filters.rb](lib/chewy/query/filters.rb) for more details.

## Faceting

Facets are an optional sidechannel you can request from Elasticsearch describing certain fields of the resulting collection. The most common use for facets is to allow the user to continue filtering specifically within the subset, as opposed to the global index.

For instance, let's request the `country` field as a facet along with our users collection. We can do this with the #facets method like so:

```ruby
UsersIndex.filter{ [...] }.facets({countries: {terms: {field: 'country'}}})
```

Let's look at what we asked from Elasticsearch. The facets setter method accepts a hash. You can choose custom/semantic key names for this hash for your own convenience (in this case I used the plural version of the actual field), in our case `countries`. The following nested hash tells ES to grab and aggregate values (terms) from the `country` field on our indexed records.

The response will include the `:facets` sidechannel:

```
< { ... ,"facets":{"countries":{"_type":"terms","missing":?,"total":?,"other":?,"terms":[{"term":"USA","count":?},{"term":"Brazil","count":?}, ...}}
```

## Aggregations

Aggregations are part of the optional sidechannel that can be requested with a query.

You interact with aggregations using the composable #aggregations method (or its alias #aggs)

Let's look at an example.

```ruby
class UsersIndex < Chewy::Index
  define_type User do
    field :name
    field :rating
  end
end

all_johns = UsersIndex::User.filter { name == 'john' }.aggs({ avg_rating: { avg: { field: 'rating' } } })

avg_johns_rating = all_johns.aggs
# => {"avg_rating"=>{"value"=>3.5}}
```

It is convenient to name aggregations that you intend to reuse regularly. This is achieve with the .aggregation method,
which is also available under the .agg alias method.

Here's the same example from before

```ruby
class UsersIndex < Chewy::Index
  define_type User do
    field :name
    field :rating, type: "long"
    agg :avg_rating do
      { avg: { field: 'rating' } }
    end
  end
end

all_johns = UsersIndex::User.filter { name == 'john' }.aggs(:avg_rating)

avg_johns_rating = all_johns.aggs
# => {"avg_rating"=>{"value"=>3.5}}
```

It is possible to run into collisions between named aggregations. This occurs when there is more than one aggregation
 with the same name. To explicitly reference an aggregation you provide a string to the #aggs method of the form:
 `index_name#document_type.aggregation_name`

Consider this example where there are two separate aggregations named `avg_rating`

```ruby
class UsersIndex < Chewy::Index
  define_type User do
    field :name
    field :rating, type: "long"
    agg :avg_rating do
      { avg: { field: 'rating' } }
    end
  end
  define_type Post do
    field :title
    field :body
    field :comments do
      field :message
      field :rating, type: "long"
    end
    agg :avg_rating do
      { avg: { field: 'comments.rating' } }
    end
  end
end

all_docs = UsersIndex.filter {match_all}.aggs("users#user.avg_rating")
all_docs.aggs
# => {"users#user.avg_rating"=>{"value"=>3.5}}
```

## Script fields

Script fields allow you to execute Elasticsearch's scripting languages such as groovy and javascript. More about supported languages and what scripting is [here](https://www.elastic.co/guide/en/elasticsearch/reference/0.90/modules-scripting.html). This feature allows you to calculate the distance between geo points, for example. This is how to use the DSL:

```ruby
UsersIndex.script_fields(
  distance: {
    params: {
      lat: 37.569976,
      lon: -122.351591
    },
    script: "doc['coordinates'].distanceInMiles(lat, lon)"
  }
)
```
Here, `coordinates` is a field with type `geo_point`. There will be a `distance` field for the index's model in the search result.

## Script scoring

Script scoring is used to score the search results. All scores are added to the search request and combined according to boost mode and score mode. This can be useful if, for example, a score function is computationally expensive and it is sufficient to compute the score on a filtered set of documents. For example, you might want to multiply the score by another numeric field in the doc:

```ruby
UsersIndex.script_score("_score * doc['my_numeric_field'].value")
```

## Boost Factor

Boost factors are a way to add a boost to a query where documents match the filter. If you have some users who are experts and some who are regular users, you might want to give the experts a higher score and boost to the top of the search results. You can accomplish this by using the #boost_factor method and adding a boost score of 5 for an expert user:

```ruby
UsersIndex.boost_factor(5, filter: {term: {type: 'Expert'}})
```

## Objects loading

It is possible to load source objects from the database for every search result:

```ruby
scope = UsersIndex.filter(range: {rating: {gte: 100}})

scope.load # => scope is marked to return User instances array
scope.load.query(...) # => since objects are loaded lazily you can complete scope
scope.load(user: { scope: ->{ includes(:country) }}) # you can also pass loading scopes for each
                                                     # possibly returned type
scope.load(user: { scope: User.includes(:country) }) # the second scope passing way.
scope.load(scope: ->{ includes(:country) }) # and more common scope applied to every loaded object type.

scope.only(:id).load # it is optimal to request ids only if you are not planning to use type objects
```

The `preload` method takes the same options as `load` and ORM/ODM objects will be loaded, but the scope will still return an array of Chewy wrappers. To access real objects use the `_object` wrapper method:

```ruby
UsersIndex.filter(range: {rating: {gte: 100}}).preload(...).query(...).map(&:_object)
```

See [loading.rb](lib/chewy/query/loading.rb) for more details.
