# Rails Settings Cached

This is improved from [rails-settings](https://github.com/ledermann/rails-settings),
added caching for all settings. Settings is a plugin that makes managing a table of
global key, value pairs easy. Think of it like a global Hash stored in your database,
that uses simple ActiveRecord like methods for manipulation. Keep track of any global
setting that you dont want to hard code into your rails app. You can store any kind
of object. Strings, numbers, arrays, or any object.

## Status

[![Gem Version](https://badge.fury.io/rb/rails-settings-cached.svg)](https://rubygems.org/gems/rails-settings-cached) [![CI Status](https://travis-ci.org/huacnlee/rails-settings-cached.svg)](http://travis-ci.org/huacnlee/rails-settings-cached) [![Code Climate](https://codeclimate.com/github/huacnlee/rails-settings-cached/badges/gpa.svg)](https://codeclimate.com/github/huacnlee/rails-settings-cached) [![codecov.io](https://codecov.io/github/huacnlee/rails-settings-cached/coverage.svg?branch=master)](https://codecov.io/github/huacnlee/rails-settings-cached?branch=master)

## Setup

Edit your Gemfile:

```ruby
gem "rails-settings-cached"
```

Generate your settings:

```bash
$ rails g settings:install
```

If you want custom model name:

```bash
$ rails g settings:install SiteConfig
```

Now just put that migration in the database with:

```bash
rake db:migrate
```

## Usage

The syntax is easy.  First, lets create some settings to keep track of:

```ruby
Setting.admin_password = 'supersecret'
Setting.date_format    = '%m %d, %Y'
Setting.cocktails      = ['Martini', 'Screwdriver', 'White Russian']
Setting.foo            = 123
Setting.credentials    = { :username => 'tom', :password => 'secret' }
```

Now lets read them back:

```ruby
Setting.foo            # returns 123
```

Changing an existing setting is the same as creating a new setting:

```ruby
Setting.foo = 'super duper bar'
```

Decide you dont want to track a particular setting anymore?

```ruby
Setting.destroy :foo
Setting.foo            # returns nil
```

Want a list of all the settings?
```ruby
Setting.get_all
```

You need name spaces and want a list of settings for a give name space? Just choose your prefered named space delimiter and use `Setting.get_all` (`Settings.all` for # Rails 3.x and 4.0.x) like this:

```ruby
Setting['preferences.color'] = :blue
Setting['preferences.size'] = :large
Setting['license.key'] = 'ABC-DEF'
# Rails 4.1.x
Setting.get_all('preferences.')
# Rails 3.x and 4.0.x
Setting.all('preferences.')
# returns { 'preferences.color' => :blue, 'preferences.size' => :large }
```

## Extend a model

Settings may be bound to any existing ActiveRecord object. Define this association like this:
Notice! is not do caching in this version.

```ruby
class User < ActiveRecord::Base
  include RailsSettings::Extend
end
```

Then you can set/get a setting for a given user instance just by doing this:

```ruby
user = User.find(123)
user.settings.color = :red
user.settings.color # returns :red
user.settings.get_all
# { "color" => :red }
```

If you want to find users having or not having some settings, there are named scopes for this:

```ruby
User.with_settings
# => returns a scope of users having any setting

User.with_settings_for('color')
# => returns a scope of users having a 'color' setting

User.without_settings
# returns a scope of users having no setting at all (means user.settings.get_all == {})

User.without_settings('color')
# returns a scope of users having no 'color' setting (means user.settings.color == nil)
```

## Default settings

Sometimes you may want define default settings.

RailsSettings has generate a config YAML file in:

```yml
# config/app.yml
defaults: &defaults
  github_token: "123456"
  twitter_token: "<%= ENV["TWITTER_TOKEN"] %>"
  foo:
    bar: "Foo bar"

development:
  <<: *defaults

test:
  <<: *defaults

production:
  <<: *defaults
```

And you can use by `Setting` model:

```
Setting.github_token
=> "123456"
Setting.github_token = "654321"
# Save into database.
Setting.github_token
# Read from databae / caching.
=> "654321"
Setting['foo.bar']
=> 'Foo bar'
```

NOTE: YAML setting it also under the cache scope, when you restart Rails application, cache will expire,
      so when you want change default config, you need restart Rails application server.

### Caching flow:

```
Setting.foo -> Check Cache -> Exist - Write Cache -> Return
                   |
                Check DB -> Exist -> Write Cache -> Return
                   |
               Check Default -> Exist -> Write Cache -> Return
                   |
               Return nil
```

## Change cache key

```ruby
class Setting < RailsSettings::Base
  cache_prefix { 'you-prefix' }
  ...
end
```

-----

## How to create a list, form to manage Settings?

If you want create an admin interface to editing the Settings, you can try methods in follow:

config/routes.rb

```rb
namespace :admin do
  resources :settings
end
```


app/controllers/admin/settings_controller.rb

```rb
module Admin
  class SettingsController < ApplicationController
    before_action :get_setting, only: [:edit, :update]

    def index
      @settings = Setting.get_all
    end

    def edit
    end

    def update
      if @setting.value != params[:setting][:value]
        @setting.value = params[:setting][:value]
        @setting.save
        redirect_to admin_settings_path, notice: 'Setting has updated.'
      else
        redirect_to admin_settings_path
      end
    end

    def get_setting
      @setting = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id])
    end
  end
end
```

app/views/admin/settings/index.html.erb

```erb
<table>
  <tr>
    <th>Key</th>
    <th></th>
  </tr>
  <% @settings.each_key do |key| %>
  <tr>
    <td><%= key %></td>
    <td><%= link_to 'edit', edit_admin_setting_path(key) %></td>
  </tr>
  <% end %>
</table>
```

app/views/admin/settings/edit.html.erb

```erb
<%= form_for(@setting, url: admin_setting_path(@setting.var), method: 'patch') do |f| %>
  <label><%= @setting.var %></label>
  <%= f.text_area :value, rows: 10 %>
  <%= f.submit %>
<% end %>
```

Also you may use [rails-settings-ui](https://github.com/accessd/rails-settings-ui) gem
for building ready to using interface with validations,
or [activeadmin_settings_cached](https://github.com/artofhuman/activeadmin_settings_cached) gem if you use [activeadmin](https://github.com/activeadmin/activeadmin).

## Use case:

- [ruby-china/ruby-china](https://github.com/ruby-china/ruby-china)
