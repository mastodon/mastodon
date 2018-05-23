# Elasticsearch::DSL

The `elasticsearch-dsl` library provides a Ruby API for
the [Elasticsearch Query DSL](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl.html).

The library is compatible with Ruby 1.9 or higher and Elasticsearch 1.0 and higher.

## Installation

Install the package from [Rubygems](https://rubygems.org):

    gem install elasticsearch-dsl

To use an unreleased version, either add it to your `Gemfile` for [Bundler](http://gembundler.com):

    gem 'elasticsearch-dsl', git: 'git://github.com/elasticsearch/elasticsearch-ruby.git'

or install it from a source code checkout:

    git clone https://github.com/elasticsearch/elasticsearch-ruby.git
    cd elasticsearch-ruby/elasticsearch-dsl
    bundle install
    rake install

## Usage

The library is designed as a group of standalone Ruby modules, classes and DSL methods,
which provide an idiomatic way to build complex
[search definitions](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-body.html).

Let's have a simple example using the declarative variant:

```ruby
require 'elasticsearch/dsl'
include Elasticsearch::DSL

definition = search do
  query do
    match title: 'test'
  end
end

definition.to_hash
# => { query: { match: { title: "test"} } }

require 'elasticsearch'
client = Elasticsearch::Client.new trace: true

client.search body: definition
# curl -X GET 'http://localhost:9200/test/_search?pretty' -d '{
#   "query":{
#     "match":{
#       "title":"test"
#     }
#   }
# }'
# ...
# => {"took"=>10, "hits"=> {"total"=>42, "hits"=> [...] } }
```

Let's build the same definition in a more imperative fashion:

```ruby
require 'elasticsearch/dsl'
include Elasticsearch::DSL

definition = Search::Search.new
definition.query = Search::Queries::Match.new title: 'test'

definition.to_hash
# => { query: { match: { title: "test"} } }
```

The library doesn't depend on an Elasticsearch client -- its sole purpose is to facilitate
building search definitions in Ruby. This makes it possible to use it with any Elasticsearch client:

```ruby
require 'elasticsearch/dsl'
include Elasticsearch::DSL

definition = search { query { match title: 'test' } }

require 'json'
require 'faraday'
client   = Faraday.new(url: 'http://localhost:9200')
response = JSON.parse(
              client.post(
                '/_search',
                JSON.dump(definition.to_hash),
                { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
              ).body
            )
# => {"took"=>10, "hits"=> {"total"=>42, "hits"=> [...] } }
```

## Features Overview

The library allows to programatically build complex search definitions for Elasticsearch in Ruby,
which are translated to Hashes, and ultimately, JSON, the language of Elasticsearch.

All Elasticsearch DSL features are supported, namely:

* [Queries](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-queries.html)
* [Filters](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-filters.html)
* [Aggregations](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-aggregations.html)
* [Suggestions](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-suggesters.html)
* [Sorting](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-sort.html)
* [Pagination](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-from-size.html)
* [Options](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-body.html) (source filtering, highlighting, etc)

An example of a complex search definition is below.

**NOTE:** In order to run the example, you have to allow restoring from the `data.elasticsearch.org` repository by adding the following configuration line to your `elasticsearch.yml`:

```yaml
repositories.url.allowed_urls: ["https://s3.amazonaws.com/data.elasticsearch.org/*"]
```

```ruby
require 'awesome_print'

require 'elasticsearch'
require 'elasticsearch/dsl'

include Elasticsearch::DSL

client = Elasticsearch::Client.new transport_options: { request: { timeout: 3600, open_timeout: 3600 } }

puts "Recovering the 'bicycles.stackexchange.com' index...".yellow

client.indices.delete index: 'bicycles.stackexchange.com', ignore: 404

client.snapshot.create_repository repository: 'data.elasticsearch.org', body: { type: 'url', settings: { url: 'https://s3.amazonaws.com/data.elasticsearch.org/bicycles.stackexchange.com/' } }
client.snapshot.restore repository: 'data.elasticsearch.org', snapshot: 'bicycles.stackexchange.com', body: { indices: 'bicycles.stackexchange.com' }
until client.cluster.health(level: 'indices')['indices']['bicycles.stackexchange.com']['status'] == 'green'
  r = client.indices.recovery(index: 'bicycles.stackexchange.com', human: true)['bicycles.stackexchange.com']['shards'][0] rescue nil
  print "\r#{r['index']['size']['recovered'] rescue '0b'} of #{r['index']['size']['total'] rescue 'N/A'}".ljust(52).gray
  sleep 1
end; puts

# The search definition
#
definition = search {
  query do

    # Use a `function_score` query to modify the default score
    #
    function_score do
      query do
        filtered do

          # Use a `multi_match` query for the fulltext part of the search
          #
          query do
            multi_match do
              query    'fixed fixie'
              operator 'or'
              fields   %w[ title^10 body ]
            end
          end

          # Use a `range` filter on the `creation_date` field
          #
          filter do
            range :creation_date do
              gte '2013-01-01'
            end
          end
        end
      end

      # Multiply the default `_score` by the document rating
      #
      functions << { script_score: { script: '_score * doc["rating"].value' } }
    end
  end

  # Calculate the most frequently used tags
  #
  aggregation :tags do
    terms do
      field 'tags'

      # Calculate average view count per tag (inner aggregation)
      #
      aggregation :avg_view_count do
        avg field: 'view_count'
      end
    end
  end

  # Calculate the posting frequency
  #
  aggregation :frequency do
    date_histogram do
      field    'creation_date'
      interval 'month'
      format   'yyyy-MM'

      # Calculate the statistics on comment count per day (inner aggregation)
      #
      aggregation :comments do
        stats field: 'comment_count'
      end
    end
  end

  # Calculate the statistical information about the number of comments
  #
  aggregation :comment_count_stats do
    stats field: 'comment_count'
  end

  # Highlight the `title` and `body` fields
  #
  highlight fields: {
    title: { fragment_size: 50 },
    body:  { fragment_size: 50 }
  }

  # Return only a selection of the fields
  #
  source ['title', 'tags', 'creation_date', 'rating', 'user.location', 'user.display_name']
}

puts "Search definition #{'-'*63}\n".yellow
ap   definition.to_hash

# Execute the search request
#
response = client.search index: 'bicycles.stackexchange.com', type: ['question','answer'], body: definition

puts "\nSearch results #{'-'*66}\n".yellow
ap   response
```

NOTE: You have to enable dynamic scripting to be able to execute the `function_score` query, either
      by adding `script.disable_dynamic: false` to your elasticsearch.yml or command line parameters.

**Please see the extensive RDoc examples in the source code and the integration tests.**

## Development

To work on the code, clone the repository and install the dependencies:

```
git clone https://github.com/elasticsearch/elasticsearch-ruby.git
cd elasticsearch-ruby/elasticsearch-dsl/
bundle install
```

Use the Rake tasks to run the test suites:

```
bundle exec rake test:unit
bundle exec rake test:integration
```

To launch a separate Elasticsearch server for integration tests,
see instructions in the main [README](../README.md#development).

## License

This software is licensed under the Apache 2 license, quoted below.

    Copyright (c) 2015 Elasticsearch <http://www.elasticsearch.org>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
