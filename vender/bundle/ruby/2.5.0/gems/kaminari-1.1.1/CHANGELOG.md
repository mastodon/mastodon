## 1.1.1

### Bug Fixes:

* Fixed a bug where `paginate ..., params: { controller: ..., action: ... }` didn't override the `params[:controller]` and `params[:action]` #919 [@chao-mu]

## 1.1.0

### Enhancements:

* Now the `page_entries_info` method respects the `I18n.locale` value when pluralizing the `entry_name` option #899 [@hundred]
* `require 'kaminari/core'` is no longer necessary when using `require 'kaminari/activerecord'` #896 [@yhara]
* Added the `#current_per_page` method to inspect current value of `per_page` #875 [#bfad]
* Better accesibility support by adding accessibility roles to pagination nav #848 [@frrrances]

### Bug Fixes:

* Fixed an issue where the command `rails g kaminari:views ...` stopped working due to a missing require #912 [@jvsoares]
* Fixed a bug where passing in `params` to the `link_to_next_page` or `link_to_previous_page` method raises an exception #874 [@5t111111]


## 1.0.1

### Bug Fixes:

* Added `required_ruby_version` to the gemspec #847 [@timoschilling]

* Fixed a regression where `per(nil)` uses `max_per_page` instead of `default_per_page` #813 [@merqlove]

* Fixed a regression where passing a String to `per()` aborts with ArgumentError #849 [@rafaelgonzalez]

* Fixed a bug where calling deprecated `max_pages_per` caused an Error on Rails 4 #852 [@tsuwatch]


## 1.0.0

### Breaking Changes:

* Dropped Ruby 1.9 support

* Dropped Rails 3.2 support

* Dropped Rails 4.0 support

* Removed Sinatra support that has been extracted to kaminari-sinatra gem

* Removed Mongoid support that has been extracted to kaminari-mongoid gem

* Removed MongoMapper support that has been extracted to kaminari-mongo_mapper gem

* Removed DataMapper support that has been extracted to kaminari-data_mapper gem

* Extracted Grape support to kaminari-grape gem and removed it from the core

* Splitted the gem into 3 internal gems:
  * The core pagination logic (kaminari-core)
  * Active Record adapter (kaminari-activerecord)
  * Action View adapter (kaminari-actionview)

* Removed deprecated `num_pages` API in favor of `total_pages`

* Deprecated `-e haml` and `-e slim` options for the views generator

* Renamed the model class method for configuring `max_pages` from `max_pages_per` to `max_pages`

### Enhancements:

* Exposed `path_to_prev_page`, `path_to_next_page` helpers as public API #683 [@neilang]

* Added `--views_prefix` option for the views generator #668 [@antstorm]

* Added `max_paginates_per` scope method to overwrite model `max_paginates_per` config #754 [@rubyonme]

* Added `:paginator_class` option to specify a custom Paginator for `paginate` #740 [@watsonbox]

* Use I18n to pluralize entries in `page_entries_info` #694 [@Linuus]

* Added `without_count` #681 [@bryanrite]

* Omit select count query for `total_count` if it's calculable in Ruby level from loaded records

### Bug Fixes:

* Fixed a bug that a single page gap was displayed as "…"

  ```
  before: ‹ 1 2 … 4 5 [6] 7 8 … 15 16 ›
  after:  ‹ 1 2 3 4 5 [6] 7 8 … 15 16 ›
  ```

* Fixed a bug where `paginate` changes request.format #540 [@jasonkim]

* Fixed a bug where `per(nil)` didn't respect `max_per_page` configuration #800 [@jonathanhefner]

* Fixed a bug that model class' `max_paginates_per` was ignored when it's smaller than the default `per_page`

* Preserve source location of the pagination method #812 [@ka8725]

* Preserve source location of the tag helpers

* Hide Next & Last buttons if page is out of range #712 [@igorkasyanchuk]

* Always buffer with `ActionView::OutputBuffer` if Action View is loaded #804 [@onemanstartup]

* Fixed `padding()` not to accept negative value #839 [@yo-gen]

* Fixed a bug where `total_count` used to return a wrong value with larger page value than total pages in `without_count` mode #845 [@denislins]

* Coerce `padding()` argument to Integer #840 [@pablocrivella]


## 0.17.0

* Rails 5 ready!

* Mongoid 5.0 support

* Dropped Ruby 1.8 support

* Dropped Mongoid 2.x support

* Extracted Sinatra support to kaminari-sinatra gem

* Extracted DataMapper support to kaminari-data_mapper gem

* Extracted Mongoid support to kaminari-mongoid gem

* Extracted MongoMapper support to kaminari-mongo_mapper gem

* Deprecated `Kaminari::PageScopeMethods#num_pages` in favor of `total_pages`

* Deprecated `:num_pages` option for `paginate` in favor of `:total_pages`

* Fixed mangled params in pagination links on Rails 5 #766 [@audionerd]

* Fixed a bug where the range of the records displayed on the last page doesn't match #718 [@danzanzini]


## 0.16.3

* Fixed a "stack level too deep" bug in mongoid #642 [@bartes]

* Fixed a bug that Kaminari possibly crashes when combined with other gems that define `inherited` method on model classes, such as aasm. #651 [@zeitnot]


## 0.16.2

* Fixed a bug where cloned Relations remember previous relations' `@total_count` value #565 [@inkstak]

* Fixed a bug where `paginate_array()` with `total_count` option returns whole array for every page #516 [@abhichvn]

* Fixed a bug where `:num_pages` option was backwards-incompatible #605 [@klebershimabuku]

* Fixed a bug where themed views generator attempts to overwrite README.md #623 [@swrobel]

* Fixed a bug that ruby raises a NameError when theme was not found #622 [@maxprokopiev]

* Fixed a bug that `paginates_per` does not work with subclasses on mongoid #634 [@kouyaf77]

* Show an error message if a proper template was not found for the generator theme #600 [@meltedice]


## 0.16.1

* Fix a bug where `:theme` option for #paginate method doesn't work properly #566 [@commstratdev]


## 0.16.0

* Add support for mongoid `max_scan` option #500 [@aptx4869]

* Add `link_to_previous_page` helper for Sinatra #504 [@ikeay]

* Add `:views_prefix` option to `#paginate` for alternative views directory #552 [@apotonick]

* Simplify `page_entries_info` by adding `entry_name` interface to each ORM

* Refer ActiveRecord::Base from top level namespace for more safety when inherited class's namespace has `ActiveRecord` constant #522 [@yuroyoro]

* Fix a bug where runtime persistence not taken into account with mongoid/kaminari #326 [@nubeod]

* Fix a bug where helper methods were not available from inside `paginator.render do ... end` block #239 [@damien-roche]

* Fix a bug where theme generator didn't work on Rails 4.1 #526 [@jimryan]

* Fix a bug that paginatable arrays with `total_count` option always returns whole array #516 [@abhichvn]


## 0.15.1

* `page_method_name` option was not working in 0.15.0 #481 [@mauriciopasquier]

* Use the mongoid criteria #length method to cache the count of the collection per criteria #484 [@camallen]

* Don't inherit `host`, `port`, and `protocol` from the given params


## 0.15.0

* Allow `count`, `total_count` to pass parameters to super #193 [@bsimpson]

* Add `max_pages` and `max_pages_per` methods to limit displayed pages per model or globally #301 [@zpieslak]

* Add support for Sinatra views overrides (add app views paths) #332 [@j15e]

* Fix wrong pagination when used with `padding` #359 [@vladimir-vg, @negipo]

* check for Hash in addition to OrderedHash, which seems to break in Rails 4, for total_count #369 [@aew]

* Make `to_s` in paginator threadsafe #374 [@bf4]

* Fix Missing partial Error when `paginate` called from different format template #381 [@joker1007]

* Add `PageScopeMethods#next_page`, `prev_page`, and `out_of_range?` [@yuki24]

* Use `html_safe` in view partials instead of `raw` fixed #73 [@zzak]

* Fix a bug that `PaginatableArray#total_pages` returns the wrong value #416 [@yuki24]

* Make `num_pages` to return the same value as `total_pages` for backward compat [@yuki24, @eitoball]

* Change `#page_entries_info` to use model name #340, #348 [@znz, @eitoball]

* Change scope to class method #433 [@kolodovskyy]

* Fix arity problem with Rails 4.1.0 #449 [@bricker]


## 0.14.1

* Changed the default "truncation" String from  "..." to "&hellip;" #264 [@pjaspers]

* The theme generator is Github API v3 compatible now! #279 [@eitoball]

* Made `Kaminari.config.default_per_page` changeable again #280 [@yuki24]


## 0.14.0

* Grape framework support! #218 [@mrplum]

* Mongoid 3 ready! #238 [@shingara]

* Added `link_to_previous_page` helper #191 [@timgremore]

* Added helper to generate rel="next" and rel="prev" link tags for SEO #200 [@joe1chen]

* Added `max_per_page` configuration option #274 [@keiko0713]

  This would be useful for the case when you are using user input `per_page` value but want to impose the upper bound.

* Added I18n to `page_entries_info` #207 [@plribeiro3000]

* Changed method name `num_pages` to `total_pages`

  `num_pages` is still available as an alias of `total_pages`, but will be deprecated or removed in some future version.

* Changed the way `page_entries_info` behave so it can show appropriate names for models with namespace #207 [@plribeiro3000]

* Added `html_safe` to `page_entries_info` helper #190 [@lucapette]

* Fixed displayed number of items on each page w/ Mongoid 2.4.x and MongoMapper #194 [@dblock]

* Removed a unused local variable from templates from default tamplate #245 [@juno]

* Fixed `page_entry_info` to use the value of `entry_name` option when given collection is empty or a PaginatableArray #265, #277 [@eitoball]

* Added require 'dm-aggregates' in DataMapper hook #259 [@shingara]


## 0.13.0

* Rails 3.2 ready! #180 [@slbug]

* DataMapper support! #149 [@NoICE, @Ragmaanir]

* Sinatra & Padrino support! #179 [@udzura, @mlightner, @aereal]

* Added mongoid embedded documents support! #155 [@yuki24]

* Added `each_relevant_page` that only visits pages in the inner or outer windows. Performance improved, particularly with very large number of pages. #154 [@cbeer]

* Memoize count for AR when calling `total_count`. Increases performance for large datasets. #138 [@sarmiena]

* Added `page_entries_info` view helper #140 [@jeffreyiacono]
  ```
  <%= page_entries_info @posts %>
  #=> Displaying posts 6 - 10 of 26 in total
  ```

* Added `link_to_next_page` helper method that simply links to the next page
  ```
  <%= link_to_next_page @posts, 'More' %>
  #=> <a href="/posts?page=7" rel="next">More</a>
  ```

* Let one override the `rel` attribute for `link_to_next_page` helper #177 [@webmat]

* Added `total_count` param for PaginatableArray. Useful for when working with RSolr #141 [@samdalton]

* Changed `Kaminari.paginate_array` API to take a Hash `options` And specifying :limit & :offset immediately builds a pagination ready object
  ```ruby
  # the following two are equivalent. Use whichever you like
  Kaminari.paginate_array((1..100).to_a, limit: 10, offset: 10)
  Kaminari.paginate_array((1..100).to_a).page(2).per(10)
  ```

* Added `padding` method to skip an arbitrary record count #60 [@aaronjensen]
  ```ruby
  User.page(2).per(10).padding(3)  # this will return users 14..23
  ```

* Made the pagination method name (defaulted to `page`) configurable #57, #162
  ```ruby
  # you can use the config file and its generator for this
  Kaminari.config.page_method_name = :paging
  Article.paging(3).per(30)
  ```

* Only add extensions to direct descendents of ActiveRecord::Base #108 [@seejohnrun]

* AR models that were subclassed before Kaminari::ActiveRecordExtension is included pick up the extensions #119 [@pivotal-casebook]

* Avoid overwriting AR::Base inherited method #165 [@briandmcnabb]

* Stopped depending on Rails gem #159 [@alsemyonov]

* introduced Travis CI #181 [@hsbt]


## 0.12.4

* Support for `config.param_name` as lambda #102 [@ajrkerr]

* Stop duplicating `order_values` #65 [@zettabyte]

* Preserve select value (e.g. "distinct") when counting #77, #104 [@tbeauvais, @beatlevic]


## 0.12.3

* Haml 3.1 Support #96 [@FlyboyArt, @sonic921]


## 0.12.2

* Added MongoMapper Support #101 [@hamin]

* Add `first_page?` and `last_page?` to `page_scope_methods` #51 [@holinnn]

* Make sure that the paginate helper always returns a String #99 [@Draiken]

* Don't remove includes scopes from count if they are needed #100 [@flop]


## 0.12.1

* Slim template support #93 [@detrain]

* Use Kaminari.config to specify default value for `param_name` #94 [@avsej]

* Fixed "super called outside of method" error happened in particular versions of Ruby 1.8.7 #91 [@Skulli]

* `_paginate.html.erb` isn't rendered with custom theme #97 [@danlunde]


## 0.12.0

* General configuration options #41 #62 [@javierv, @iain]

  You can now globally override some default values such as `default_per_page`, `window`, etc. via configuration file.
  Also, here comes a generator command that generates the default configuration file into your app's config/initilizers directory.

* Generic pagination support for Array object #47 #68 #74 [@lda, @ened, @jianlin]

  You can now paginate through any kind of Arrayish object in this way:
  ```ruby
  Kaminari.paginate_array(my_array_object).page(params[:page]).per(10)
  ```

* Fixed a serious performance regression on #count method in 0.11.0 [@ankane]

* Bugfix: Pass the real @params to `url_for` #90 [@utkarshkukreti]

* Fixed a gem packaging problem (circular dependency)

  There was a packaging problem with Kaminari 0.11.0 that the gem depends on Kaminari gem. Maybe Jeweler + "gemspec" method didn't work well...


## 0.11.0

This release contains several backward incompatibilities on template API. You probably need to update your existing templates if you're already using your own custom theme.

* Merge `_current_page`, `_first_page_link`, `_last_page_link` and `_page_link` into one `_page` partial #28 [@GarthSnyder]

* Add real first/last page links, and use them by default instead of outer window #30 [@GarthSnyder]

* The disabled items should simply not be emitted, even as an empty span #30 [@GarthSnyder]

* Skip :order in `#count_all` so complex groups with generated columns don't blow up in SQL-land #61 [@keeran, @Empact]

* Ignore :include in `#count_all` to make it work better with polymorphic eager loading #80 [@njakobsen]

* Quick fix on `#count` to return the actual number of records on AR 3.0 #45 #50

* Removed "TERRIBLE HORRIBLE NO GOOD VERY BAD HACK" #82 [@janx, @flop, @pda]

* Allow for Multiple Themes #64 [@tmilewski]

* Themes can contain the whole application directory structure now

* Use `gemspec` method in Gemfile [@p_elliott]


## 0.10.4

* Do not break ActiveRecord::Base.descendants, by making sure to call super from ActiveRecord::Base.inherited #34 [@rolftimmermans]

* Fixed vanishing mongoid criteria after calling `page()` #26 [@tyok]


## 0.10.3

* Fixed a bug that `total_count()` didn't work when chained with `group()` scope #21 [@jgeiger]

* Fixed a bug that the paginate helper didn't work properly with an Ajax call #23 [@hjuskewycz]


## 0.10.2

* Added `:param_name` option to the pagination helper #10 [@ivanvr]

   ```haml
   = paginate @users, :param_name => :pagina
   ```


## 0.10.1

* Fixed a bug that the whole `<nav>` section was not rendered in some cases [@GarthSnyder]


## 0.10.0

* Railtie initializer name is "kaminari" from now

* Changed bundler settings to work both on 1.9.2 and 1.8.7 #12 [@l15n]

* Fixed bugs encountered when running specs on Ruby 1.9.2 #12 [@l15n]

* Clean up documentation (formatting and editing) #12 [@l15n]

* Use `Proc.new` instead of lambda for `scoped_options` #13 [@l15n]

* Use AS hooks for loading AR #14 [@hasimo]

* Refactor scope definition with Concerns #15 [@l15n]

* Ensure `output_buffer` is always initialized #11 [@kichiro]


## 0.9.13

* Added Mongoid support #5 [@juno, @hibariya]

  This means, Kaminari is now *ORM agnostic*  ☇3☇3☇3


## 0.9.12

* Moved the whole pagination logic to the paginator partial so that users can touch it

  Note: You need to update your `_paginator.html.*` if you've already customized it.
  If you haven't overridden `_paginator.html.*` files, then probably there're nothing you have to do.
  See this commit for the example: https://github.com/amatsuda/kaminari_themes/commit/2dfb41c

## 0.9.10

* the `per()` method accepts String, zero and minus value now #7 [@koic]

  This enables you to do something like this:
  ```ruby
	Model.page(params[:page]).per(params[:per])
  ```

* Added support for Gem Testers (http://gem-testers.org/) #8 [@joealba]


## 0.9.9

* `:params` option for the helper [@yomukaku_memo]

  You can override each link's `url_for` option by this option
  ```haml
  = paginate @users, :params => {:controller => 'users', :action => 'index2'}
  ```

* refactor tags


## 0.9.8

* I18n for the partials `:previous`, `:next`, and `:truncate` are externalized to the I18n resource.


## 0.9.7

* moved template themes to another repo https://github.com/amatsuda/kaminari_themes


## 0.9.6

* added `paginates_per` method for setting default `per_page` value for each model in a declarative way

  ```ruby
  class Article < ActiveRecord::Base
    paginates_per 10
  end
  ```


## 0.9.5

* works on AR 3.0.0 and 3.0.1 now #4 [@danillos]


## 0.9.4

* introduced module based tags

  As a side effect of this internal change, I have to confess that this version brings you a slight backward incompatibility on template API.
  If you're using custom templates, be sure to update your existing templates. To catch up the new API, you need to update %w[next_url prev_url page_url] local variables to simple 'url' like this.  https://github.com/amatsuda/kaminari/commit/da88729


## 0.9.3

* improved template detection logic

  When a template for a tag could not be found in the app/views/kaminari/ directory, it searches the tag's ancestor template files before falling back to engine's default template. This may help keeping your custom templates DRY.

* simplified bundled template themes


## 0.9.2

* stop adding extra LF between templates when joining

* githubish template theme [@maztomo]


## 0.9.1

* googlish template theme [@maztomo]


## 0.9.0

* added `per_page` to the template local variables #3 [@hsbt]

* show no contents when the current page is the only page (in other words, `num_pages == 1`) #2 [@hsbt]


## 0.8.0

* using HTML5 `<nav>` tag rather than `<div>` for the container tag


## 0.7.0

* Ajaxified paginator templates


## 0.6.0

* Hamlized paginator templates


## 0.5.0

* reset `content_for :kaminari_paginator_tags` before rendering #1 [@hsbt]


## 0.4.0

* partialize the outer div


## 0.3.0

* suppress logging when rendering each partial


## 0.2.0

* default `PER_PAGE` to 25 [@hsbt]


## 0.1.0

* First release
