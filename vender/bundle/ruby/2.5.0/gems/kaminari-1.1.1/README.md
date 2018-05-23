# Kaminari [![Build Status](https://travis-ci.org/kaminari/kaminari.svg)](http://travis-ci.org/kaminari/kaminari) [![Code Climate](https://codeclimate.com/github/kaminari/kaminari/badges/gpa.svg)](https://codeclimate.com/github/kaminari/kaminari) [![Inch CI](http://inch-ci.org/github/kaminari/kaminari.svg)](http://inch-ci.org/github/kaminari/kaminari)

A Scope & Engine based, clean, powerful, customizable and sophisticated paginator for modern web app frameworks and ORMs

## Features

### Clean
Does not globally pollute `Array`, `Hash`, `Object` or `AR::Base`.

### Easy to Use
Just bundle the gem, then your models are ready to be paginated.
No configuration required.
Don't have to define anything in your models or helpers.

### Simple Scope-based API
Everything is method chainable with less "Hasheritis". You know, that's the modern Rails way.
No special collection class or anything for the paginated values, instead using a general `AR::Relation` instance.
So, of course you can chain any other conditions before or after the paginator scope.

### Customizable Engine-based I18n-aware Helpers
As the whole pagination helper is basically just a collection of links and non-links, Kaminari renders each of them through its own partial template inside the Engine.
So, you can easily modify their behaviour, style or whatever by overriding partial templates.

### ORM & Template Engine Agnostic
Kaminari supports multiple ORMs (ActiveRecord, DataMapper, Mongoid, MongoMapper) multiple web frameworks (Rails, Sinatra, Grape), and multiple template engines (ERB, Haml, Slim).

### Modern
The pagination helper outputs the HTML5 `<nav>` tag by default. Plus, the helper supports Rails unobtrusive Ajax.


## Supported Versions

* Ruby 2.0.0, 2.1.x, 2.2.x, 2.3.x, 2.4.x, 2.5

* Rails 4.1, 4.2, 5.0, 5.1, 5.2

* Sinatra 1.4

* Haml 3+

* Mongoid 3+

* MongoMapper 0.9+

* DataMapper 1.1.0+


## Installation

To install kaminari on the default Rails stack, just put this line in your Gemfile:

```ruby
gem 'kaminari'
```

Then bundle:

```sh
% bundle
```

If you're building non-Rails of non-ActiveRecord app and want the pagination feature on it, please take a look at [Other Framework/Library Support](#other-frameworklibrary-support) section.


## Query Basics

### The `page` Scope

To fetch the 7th page of users (default `per_page` is 25)

```ruby
User.page(7)
```

Note: pagination starts at page 1, not at page 0 (page(0) will return the same results as page(1)).

You can get page numbers or page conditions by using below methods.
```ruby
User.count                     #=> 1000
User.page(1).limit_value       #=> 20
User.page(1).total_pages       #=> 50
User.page(1).current_page      #=> 1
User.page(1).next_page         #=> 2
User.page(2).prev_page         #=> 1
User.page(1).first_page?       #=> true
User.page(50).last_page?       #=> true
User.page(100).out_of_range?   #=> true
```

### The `per` Scope

To show a lot more users per each page (change the `per_page` value)

```ruby
User.page(7).per(50)
```

Note that the `per` scope is not directly defined on the models but is just a method defined on the page scope.
This is absolutely reasonable because you will never actually use `per_page` without specifying the `page` number.

Keep in mind that `per` internally utilizes `limit` and so it will override any `limit` that was set previously.
And if you want to get the size for all request records you can use `total_count` method:

```ruby
User.count                     #=> 1000
a = User.limit(5); a.count     #=> 5
a.page(1).per(20).size         #=> 20
a.page(1).per(20).total_count  #=> 1000
```

### The `padding` Scope

Occasionally you need to pad a number of records that is not a multiple of the page size.

```ruby
User.page(7).per(50).padding(3)
```

Note that the `padding` scope also is not directly defined on the models.


## Configuring Kaminari

### General Configuration Options

You can configure the following default values by overriding these values using `Kaminari.configure` method.

    default_per_page      # 25 by default
    max_per_page          # nil by default
    max_pages             # nil by default
    window                # 4 by default
    outer_window          # 0 by default
    left                  # 0 by default
    right                 # 0 by default
    page_method_name      # :page by default
    param_name            # :page by default
    params_on_first_page  # false by default

There's a handy generator that generates the default configuration file into config/initializers directory.
Run the following generator command, then edit the generated file.

```sh
% rails g kaminari:config
```

### Changing `page_method_name`

You can change the method name `page` to `bonzo` or `plant` or whatever you like, in order to play nice with existing `page` method or association or scope or any other plugin that defines `page` method on your models.


### Configuring Default per_page Value for Each Model by `paginates_per`

You can specify default `per_page` value per each model using the following declarative DSL.

```ruby
class User < ActiveRecord::Base
  paginates_per 50
end
```

### Configuring Max per_page Value for Each Model by `max_paginates_per`

You can specify max `per_page` value per each model using the following declarative DSL.
If the variable that specified via `per` scope is more than this variable, `max_paginates_per` is used instead of it.
Default value is nil, which means you are not imposing any max `per_page` value.

```ruby
class User < ActiveRecord::Base
  max_paginates_per 100
end
```


## Controllers

### The Page Parameter Is in `params[:page]`

Typically, your controller code will look like this:

```ruby
@users = User.order(:name).page params[:page]
```


## Views

### The Same Old Helper Method

Just call the `paginate` helper:

```erb
<%= paginate @users %>
```

This will render several `?page=N` pagination links surrounded by an HTML5 `<nav>` tag.


## Helpers

### The `paginate` Helper Method

```erb
<%= paginate @users %>
```

This would output several pagination links such as `« First ‹ Prev ... 2 3 4 5 6 7 8 9 10 ... Next › Last »`

### Specifying the "inner window" Size (4 by default)

```erb
<%= paginate @users, window: 2 %>
```

This would output something like `... 5 6 7 8 9 ...` when 7 is the current
page.

### Specifying the "outer window" Size (0 by default)

```erb
<%= paginate @users, outer_window: 3 %>
```

This would output something like `1 2 3 ...(snip)... 18 19 20` while having 20 pages in total.

### Outer Window Can Be Separately Specified by left, right (0 by default)

```erb
<%= paginate @users, left: 1, right: 3 %>
```

This would output something like `1 ...(snip)... 18 19 20` while having 20 pages in total.

### Changing the Parameter Name (`:param_name`) for the Links

```erb
<%= paginate @users, param_name: :pagina %>
```

This would modify the query parameter name on each links.

### Extra Parameters (`:params`) for the Links

```erb
<%= paginate @users, params: {controller: 'foo', action: 'bar'} %>
```

This would modify each link's `url_option`. :`controller` and :`action` might be the keys in common.

### Ajax Links (crazy simple, but works perfectly!)

```erb
<%= paginate @users, remote: true %>
```

This would add `data-remote="true"` to all the links inside.

### Specifying an Alternative Views Directory (default is kaminari/)

```erb
<%= paginate @users, views_prefix: 'templates' %>
```

This would search for partials in `app/views/templates/kaminari`.
This option makes it easier to do things like A/B testing pagination templates/themes, using new/old templates at the same time as well as better integration with other gems such as [cells](https://github.com/apotonick/cells).

### The `link_to_next_page` and `link_to_previous_page` (aliased to `link_to_prev_page`) Helper Methods

```erb
<%= link_to_next_page @items, 'Next Page' %>
```

This simply renders a link to the next page. This would be helpful for creating a Twitter-like pagination feature.

### The `page_entries_info` Helper Method

```erb
<%= page_entries_info @posts %>
```

This renders a helpful message with numbers of displayed vs. total entries.

By default, the message will use the humanized class name of objects in collection: for instance, "project types" for ProjectType models.
The namespace will be cut out and only the last name will be used. Override this with the `:entry_name` parameter:

```erb
<%= page_entries_info @posts, entry_name: 'item' %>
#=> Displaying items 6 - 10 of 26 in total
```

### The `rel_next_prev_link_tags` Helper Method

```erb
<%= rel_next_prev_link_tags @users %>
```

This renders the rel next and prev link tags for the head.

### The `path_to_next_page` Helper Method

```erb
<%= path_to_next_page @users %>
```

This returns the server relative path to the next page.

### The `path_to_prev_page` Helper Method

```erb
<%= path_to_prev_page @users %>
```

This returns the server relative path to the previous page.


## I18n and Labels

The default labels for 'first', 'last', 'previous', '...' and 'next' are stored in the I18n yaml inside the engine, and rendered through I18n API.
You can switch the label value per I18n.locale for your internationalized application.  Keys and the default values are the following. You can override them by adding to a YAML file in your `Rails.root/config/locales` directory.

```yaml
en:
  views:
    pagination:
      first: "&laquo; First"
      last: "Last &raquo;"
      previous: "&lsaquo; Prev"
      next: "Next &rsaquo;"
      truncate: "&hellip;"
  helpers:
    page_entries_info:
      one_page:
        display_entries:
          zero: "No %{entry_name} found"
          one: "Displaying <b>1</b> %{entry_name}"
          other: "Displaying <b>all %{count}</b> %{entry_name}"
      more_pages:
        display_entries: "Displaying %{entry_name} <b>%{first}&nbsp;-&nbsp;%{last}</b> of <b>%{total}</b> in total"
```

If you use non-English localization see [i18n rules](https://github.com/svenfuchs/i18n/blob/master/test/test_data/locales/plurals.rb) for changing
`one_page:display_entries` block.


## Customizing the Pagination Helper

Kaminari includes a handy template generator.

### To Edit Your Paginator

Run the generator first,

```sh
% rails g kaminari:views default
```

then edit the partials in your app's `app/views/kaminari/` directory.

### For Haml/Slim Users

You can use the [html2haml gem](https://github.com/haml/html2haml) or the [html2slim gem](https://github.com/slim-template/html2slim) to convert erb templates.
The kaminari gem will automatically pick up haml/slim templates if you place them in `app/views/kaminari/`.

### Multiple Templates

In case you need different templates for your paginator (for example public and admin), you can pass `--views-prefix directory` like this:

```sh
% rails g kaminari:views default --views-prefix admin
```

that will generate partials in `app/views/admin/kaminari/` directory.

### Themes

The generator has the ability to fetch several sample template themes from the external repository (https://github.com/amatsuda/kaminari_themes) in addition to the bundled "default" one, which will help you creating a nice looking paginator.

```sh
% rails g kaminari:views THEME
```

To see the full list of available themes, take a look at the themes repository, or just hit the generator without specifying `THEME` argument.

```sh
% rails g kaminari:views
```

### Multiple Themes

To utilize multiple themes from within a single application, create a directory within the app/views/kaminari/ and move your custom template files into that directory.

```sh
% rails g kaminari:views default (skip if you have existing kaminari views)
% cd app/views/kaminari
% mkdir my_custom_theme
% cp _*.html.* my_custom_theme/
```

Next, reference that directory when calling the `paginate` method:

```erb
<%= paginate @users, theme: 'my_custom_theme' %>
```

Customize away!

Note: if the theme isn't present or none is specified, kaminari will default back to the views included within the gem.


## Paginating Without Issuing SELECT COUNT Query

Generally the paginator needs to know the total number of records to display the links, but sometimes we don't need the total number of records and just need the "previous page" and "next page" links.
For such use case, Kaminari provides `without_count` mode that creates a paginatable collection without counting the number of all records.
This may be helpful when you're dealing with a very large dataset because counting on a big table tends to become slow on RDBMS.

Just add `.without_count` to your paginated object:

```ruby
User.page(3).without_count
```

In your view file, you can only use simple helpers like the following instead of the full-featured `paginate` helper:

```erb
<%= link_to_prev_page @users, 'Previous Page' %>
<%= link_to_next_page @users, 'Next Page' %>
```


## Paginating a Generic Array object

Kaminari provides an Array wrapper class that adapts a generic Array object to the `paginate` view helper. However, the `paginate` helper doesn't automatically handle your Array object (this is intentional and by design).
`Kaminari::paginate_array` method converts your Array object into a paginatable Array that accepts `page` method.

```ruby
@paginatable_array = Kaminari.paginate_array(my_array_object).page(params[:page]).per(10)
```

You can specify the `total_count` value through options Hash. This would be helpful when handling an Array-ish object that has a different `count` value from actual `count` such as RSolr search result or when you need to generate a custom pagination. For example:

```ruby
@paginatable_array = Kaminari.paginate_array([], total_count: 145).page(params[:page]).per(10)
```


## Creating Friendly URLs and Caching

Because of the `page` parameter and Rails routing, you can easily generate SEO and user-friendly URLs. For any resource you'd like to paginate, just add the following to your `routes.rb`:

```ruby
resources :my_resources do
  get 'page/:page', action: :index, on: :collection
end
```

If you are using Rails 4 or later, you can simplify route definitions by using `concern`:

```ruby
concern :paginatable do
  get '(page/:page)', action: :index, on: :collection, as: ''
end

resources :my_resources, concerns: :paginatable
```

This will create URLs like `/my_resources/page/33` instead of `/my_resources?page=33`. This is now a friendly URL, but it also has other added benefits...

Because the `page` parameter is now a URL segment, we can leverage on Rails page [caching](http://guides.rubyonrails.org/caching_with_rails.html#page-caching)!

NOTE: In this example, I've pointed the route to my `:index` action. You may have defined a custom pagination action in your controller - you should point `action: :your_custom_action` instead.


## Other Framework/Library Support

### The kaminari gem

Technically, the kaminari gem consists of 3 individual components:

    kaminari-core: the core pagination logic
    kaminari-activerecord: Active Record adapter
    kaminari-actionview: Action View adapter

So, bundling `gem 'kaminari'` is equivalent to the following 2 lines (kaminari-core is referenced from the adapters):

```ruby
gem 'kaminari-activerecord'
gem 'kaminari-actionview'
```

### For Other ORM Users

If you want to use other supported ORMs instead of ActiveRecord, for example Mongoid, bundle its adapter instead of kaminari-activerecord.

```ruby
gem 'kaminari-mongoid'
gem 'kaminari-actionview'
```

Kaminari currently provides adapters for the following ORMs:

* Active Record: https://github.com/kaminari/kaminari/tree/master/kaminari-activerecord  (included in this repo)
* Mongoid: https://github.com/kaminari/kaminari-mongoid
* MongoMapper: https://github.com/kaminari/kaminari-mongo_mapper
* DataMapper: https://github.com/kaminari/kaminari-data_mapper  (would not work on kaminari 1.0.x)

### For Other Web Framework Users

If you want to use other web frameworks instead of Rails + Action View, for example Sinatra, bundle its adapter instead of kaminari-actionview.

```ruby
gem 'kaminari-activerecord'
gem 'kaminari-sinatra'
```

Kaminari currently provides adapters for the following web frameworks:

* Action View: https://github.com/kaminari/kaminari/tree/master/kaminari-actionview  (included in this repo)
* Sinatra: https://github.com/kaminari/kaminari-sinatra
* Grape: https://github.com/kaminari/kaminari-grape


## For More Information

Check out Kaminari recipes on the GitHub Wiki for more advanced tips and techniques. https://github.com/kaminari/kaminari/wiki/Kaminari-recipes


## Questions, Feedback

Feel free to message me on Github (amatsuda) or Twitter ([@a_matsuda](https://twitter.com/a_matsuda))  ☇☇☇  :)


## Contributing to Kaminari

Fork, fix, then send a pull request.

To run the test suite locally against all supported frameworks:

```sh
% bundle install
% rake test:all
```

To target the test suite against one framework:

```sh
% rake test:active_record_50
```

You can find a list of supported test tasks by running `rake -T`. You may also find it useful to run a specific test for a specific framework. To do so, you'll have to first make sure you have bundled everything for that configuration, then you can run the specific test:

```sh
% BUNDLE_GEMFILE='gemfiles/active_record_50.gemfile' bundle install
% BUNDLE_GEMFILE='gemfiles/active_record_50.gemfile' TEST=kaminari-core/test/requests/navigation_test.rb bundle exec rake test
```


## Copyright

Copyright (c) 2011- Akira Matsuda. See MIT-LICENSE for further details.
