[Back to Guides](../README.md)

# How to add pagination links

### JSON API adapter

Pagination links will be included in your response automatically as long as
the resource is paginated and if you are using the ```JsonApi``` adapter.

If you want pagination links in your response, use [Kaminari](https://github.com/amatsuda/kaminari)
or [WillPaginate](https://github.com/mislav/will_paginate).

Although the other adapters do not have this feature, it is possible to
implement pagination links to `JSON` adapter. For more information about it,
please check our docs.

###### Kaminari examples

```ruby
#array
@posts = Kaminari.paginate_array([1, 2, 3]).page(3).per(1)
render json: @posts

#active_record
@posts = Post.page(3).per(1)
render json: @posts
```

###### WillPaginate examples

```ruby
#array
@posts = [1,2,3].paginate(page: 3, per_page: 1)
render json: @posts

#active_record
@posts = Post.page(3).per_page(1)
render json: @posts
```

```ruby
ActiveModelSerializers.config.adapter = :json_api
```

ex:
```json
{
  "data": [
    {
      "type": "articles",
      "id": "3",
      "attributes": {
        "title": "JSON API paints my bikeshed!",
        "body": "The shortest article. Ever.",
        "created": "2015-05-22T14:56:29.000Z",
        "updated": "2015-05-22T14:56:28.000Z"
      }
    }
  ],
  "links": {
    "self": "http://example.com/articles?page[number]=3&page[size]=1",
    "first": "http://example.com/articles?page[number]=1&page[size]=1",
    "prev": "http://example.com/articles?page[number]=2&page[size]=1",
    "next": "http://example.com/articles?page[number]=4&page[size]=1",
    "last": "http://example.com/articles?page[number]=13&page[size]=1"
  }
}
```

ActiveModelSerializers pagination relies on a paginated collection with the methods `current_page`, `total_pages`, and `size`, such as are supported by both [Kaminari](https://github.com/amatsuda/kaminari) or [WillPaginate](https://github.com/mislav/will_paginate).


### JSON adapter

If you are not using `JSON` adapter, pagination links will not be included automatically, but it is possible to do so using `meta` key.

Add this method to your base API controller.

```ruby
def pagination_dict(collection)
  {
    current_page: collection.current_page,
    next_page: collection.next_page,
    prev_page: collection.prev_page, # use collection.previous_page when using will_paginate
    total_pages: collection.total_pages,
    total_count: collection.total_count
  }
end
```

Then, use it on your render method.

```ruby
render json: posts, meta: pagination_dict(posts)
```

ex.
```json
{
  "posts": [
    {
      "id": 2,
      "title": "JSON API paints my bikeshed!",
      "body": "The shortest article. Ever."
    }
  ],
  "meta": {
    "current_page": 3,
    "next_page": 4,
    "prev_page": 2,
    "total_pages": 10,
    "total_count": 10
  }
}
```

You can also achieve the same result if you have a helper method that adds the pagination info in the meta tag. For instance, in your action specify a custom serializer.

```ruby
render json: @posts, each_serializer: PostPreviewSerializer, meta: meta_attributes(@posts)
```

```ruby
#expects pagination!
def meta_attributes(collection, extra_meta = {})
  {
    current_page: collection.current_page,
    next_page: collection.next_page,
    prev_page: collection.prev_page, # use collection.previous_page when using will_paginate
    total_pages: collection.total_pages,
    total_count: collection.total_count
  }.merge(extra_meta)
end
```

### Attributes adapter

This adapter does not allow us to use `meta` key, due to that it is not possible to add pagination links.
