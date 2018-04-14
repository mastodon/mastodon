[Back to Guides](../README.md)

# Deserialization

This is currently an *experimental* feature. The interface may change.

## JSON API

The `ActiveModelSerializers::Deserialization` defines two methods (namely `jsonapi_parse` and `jsonapi_parse!`), which take a `Hash` or an instance of `ActionController::Parameters` representing a JSON API payload, and return a hash that can directly be used to create/update models. The bang version throws an `InvalidDocument` exception when parsing fails, whereas the "safe" version simply returns an empty hash.

- Parameters
  - document: `Hash` or `ActionController::Parameters` instance
  - options:
    - only: `Array` of whitelisted fields
    - except: `Array` of blacklisted fields
    - keys: `Hash` of fields the name of which needs to be modified (e.g. `{ :author => :user, :date => :created_at }`)

Examples:

```ruby
class PostsController < ActionController::Base
  def create
    Post.create(create_params)
  end

  def create_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:title, :content, :author])
  end
end
```



Given a JSON API document,

```
document = {
  'data' => {
    'id' => 1,
    'type' => 'post',
    'attributes' => {
      'title' => 'Title 1',
      'date' => '2015-12-20'
    },
    'relationships' => {
      'author' => {
        'data' => {
          'type' => 'user',
          'id' => '2'
        }
      },
      'second_author' => {
        'data' => nil
      },
      'comments' => {
        'data' => [{
          'type' => 'comment',
          'id' => '3'
        },{
          'type' => 'comment',
          'id' => '4'
        }]
      }
    }
  }
}
```

The entire document can be parsed without specifying any options:
```ruby
ActiveModelSerializers::Deserialization.jsonapi_parse(document)
#=>
# {
#   title: 'Title 1',
#   date: '2015-12-20',
#   author_id: 2,
#   second_author_id: nil
#   comment_ids: [3, 4]
# }
```

and fields, relationships, and polymorphic relationships can be specified via the options:

```ruby
ActiveModelSerializers::Deserialization
  .jsonapi_parse(document, only: [:title, :date, :author],
                           keys: { date: :published_at },
                           polymorphic: [:author])
#=>
# {
#   title: 'Title 1',
#   published_at: '2015-12-20',
#   author_id: '2',
#   author_type: 'user'
# }
```

## Attributes/Json

There is currently no deserialization for those adapters.
