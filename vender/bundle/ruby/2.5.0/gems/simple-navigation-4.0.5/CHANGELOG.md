# Changelog

## 4.0.5

* Fix #188 Blank url and highligh_on_subpath = true causes error. Credits to Tristan Harmer (gondalez) and Ilia Pozhilov (ilyapoz).

## 4.0.4

* Fix #184 uninitialized constant Rails::Railtie (NameError). Credits to n-rodriguez.

## 4.0.3

* Fix #180 Check URL before invoking current_page?

## 4.0.2

* fixing current_page? when url is nil

## 4.0.1

* fixed padrino adapter

## 4.0.0

* added two new configuration options ignore_query_params_on_auto_highlight and ignore_anchors_on_auto_highlight
* Remove dependency on classic-style Sinatra applications and enable use with modular-style apps. Credits to Stefan Kolb.
* Item can now receive a block as `name`
* It's now possible to set a global `highlight_on_subpath` option instead of adding it to every item
* Creating an Item doesn't remove options anymore
* Creating an Item no longer changed its container, only adding it to a container
  does
* `Item#autogenerate_item_ids?` has been removed
* `SN.config_file_name`, `SN.config_file` and `SN.config_file?` have been
  removed
* `ConfigFileFinder` and `ConfigFile` handle the configuration logic
* File organization was been changed to reflect the Ruby namespacing

## 3.13.0

* consider_item_names_as_safe is now false by default. Removed deprecation warning

## 3.12.2

* Fixing issue #154. Thanks to Simon Curtois.

## 3.12.1

* bugfix (error in generator)

## 3.12.0

* Relax hash constraint on item_adapter. Thanks to Ramon Tayag.
* Fixed hidden special character in navigation template. Credits to Stef
  Lewandowski
* Added full MIT license text. Thanks to Ben Armstrong.
* Added license to gemspec. Thanks to Troy Thompson.
* Allow defining other html attributes than :id and :class on menu container.
  Credits to Jacek Tomaszewski.
* Added new config option "consider_item_names_as_safe". Thanks to Alexey
  Naumov.
* Big cleanup of specs, removed jeweler in favor of the "bundler" way. Huge
  thank you to Simon Courtois.
* Added more powerful name generator which yields the item itself in addition to
  the item's name. Credits to Simon Curtois.

## 3.11.0

* Added Json renderer. Thanks to Alberto Avila.

## 3.10.1

* Padrino adapter now returns "html_safe"d content_tag

## 3.10.0

* Added ability to set selected_class on container level. Credits to Joost
  Hietbrink.
* do not highlight items that are only partial matches. Thanks to Troy Thompson.
* adding support for rails 4. Credits to Samer Masry.

## 3.9.0

* Added ability to pass a block to render_navigation for configuring dynamic
  navigation items (instead of passing :items). Credits to Ronald Chan.

## 3.8.0

* Changed the way the context is fetched. Fixes incompatibility with Gretel.
  Thanks to Ivan Kasatenko.
* Added :join_with option to links renderer. Thanks to Stefan Melmuk.
* Added :prefix option to breadcrumb renderer. Credits to Rodrigo Manhães.
* Added :ordered option for allowing list renderer to render an `<ol>` rather
  than a `<ul>`.
* Sinatra adapter no longer renders attributes with nil values as attributes
  with empty strings in the output, instead electing not to render the attribute
  at all. Thanks to revdan for pointing this out.

## 3.7.0

* Added new adapater for working with the Nanoc static site generation
  framework.
* Fix issue #22 - last link in a breadcrumb trail may now be rendered as static
  text insted by supplying :static_leaf => true as an option
* Allow breadcrumbs to be provided with link id and classes by supplying
  `:allow_classes_and_ids => true` as an option

## 3.6.0

* Added linkless items functionality - the `url` parameter is now optional,
  items which aren't links will be rendered within a 'span' element rather than
  an 'a' element. `options` remain optional (defaults to an empty Hash).
  `options` may be provided without providing a `url` (detected by checking if
  the `url` parameter is a Hash or otherwise).

## 3.5.1

* Fixed specs related to testing name_generator functionality - stub the
  name_generator method rather than calling it to ensure subsequent tests aren't
  affected.

## 3.5.0

* Added (configurable) "simple-navigation-active-leaf" class to last selected
  element and elements that have :highlights_on return true. Thanks to Frank
  Schumacher (thenoseman).

## 3.4.2

* Improve Gemfile dependencies with :development and :rails groups.

## 3.4.1

* Rerelease using ruby-1.8.7 rather than ruby-1.9.2 in order that the
  rubygems.org gemspec is generated in a compatible fashion.

## 3.4.0

* Added Gemfile for easier development with Bundler. Thanks to Josep Jaume.
* modified :highlights_on option to accept a :subpath option (as well as Proc
  and Regexp forms). This can be used to automatically highlight an item even
  for items within a subpath.  Thanks to Josep Jaume.

## 3.3.4

* modified :highlights_on option to accept a Proc (as well as the existing
  Regexp form). This can be used to provide specific highlighting conditions
  inline. Thanks to superlou for sparking the idea for the concept.

## 3.3.3

* Bugfix in Adapters::Sinatra#current_url? (compares unencoded URIs). Thanks to
  Matthew Gast.

## 3.3.2

* The patch listed in 3.3.1 somehow did not make it into the gem... sorry.
  Re-releasing...

## 3.3.1

* bugfix in sinatra adapter. Use Rack::Request#scheme instead of
  `Rack::Request#protocol`. Credits to Matthew Gast.

## 3.3.0

* add a new method `active_navigation_item_key` which returns the symbol for the
  currently selected navigation item in a similar way to
  `active_navigation_item_name` does for the name (useful for CSS class styling
  for eg.)
* open up the helper API to provide `active_navigation_item` and
  `active_navigation_item_container` methods to make it easy to access the
  items/containers should it be necessary (came for free with the above
  refactoring)
* isolate the apply_defaults and load_config private methods from
  `ActionController` mixin leakage by refactoring to module class instance
  methods
* addition of test coverage for the added helpers within helpers_spec.rb
* inclusion of new helpers within the rails adapter and minor refactoring to DRY
  up the helper_method invocations
* addition of test coverage for the newly included helpers
* Credits to Mark J. Titorenko for all the changes in this release! Thanks.

## 3.2.0

* Added Renderer::Text for rendering selected navigation items without markup
  (useful for dynamic page titles). Credits to Tim Cowlishaw.
* Added ability to add custom markup around item names specifying a
  `name_generator` in the config file. Thanks to Jack Dempsey.

## 3.1.1

* `Item#selected_by_url?` now strips anchors from the item's url before
  comparing it with the current request's url. Credits to opengovernment.

## 3.1.0

* added new helper method `active_navigation_item_name` to render the name of
  the currently active item

## 3.0.2

* `dom_id` and `dom_class` can now be set as option in the item's definition
  (useful for dynamic menu items).

## 3.0.1

* allow controller instance variables named @template for rails3 apps. Credits
  to cmartyn.
* added possibility to specify and item's URL as a block which is evaulated
  after the :if and :unless conditions have been checked. Credits to Nicholas
  Firth-McCoy.
* upgraded to rspec 2.0.0
* fixed cgi error in sinatra adapter. Credits to Jack Dempsey.

## 3.0.0

* added ability to specify dynamic items using an array of hashes. Credits to
  Anshul Khandelwal for input and discussion.
* added ability to specify attributes for the generated link-tag in list
  renderer (up to now the attributes have been applied to the li-tag). Credits
  to Anthony Navarre for input and discussion.

## 3.0.0.beta2

* moving code for initializing plugin in sinatra to separate gem

## 3.0.0.beta1

* moving deprecated rails controller methods (navigation, current_navigation) to
  separate file 'rails_controller_methods'. Deprecations removed. File can be
  required explicitly if controller methods should be still available.
* decoupling from Rails. Introducing the concept of adapters to work with
  several frameworks.
* tested with Rails 3.0.0
* adding support for Sinatra and Padrino frameworks.
* cherry picking active_support stuff instead of requiring the whole bunch
  (tested with active_support >= 2.3.2 and 3.0.0)
* created public sample project which includes demo for Rails2, Rails3, Sinatra
  and Padrino (will be available on github soon)
* better src file organization (adapters/core/rendering folders)

## 2.7.3

* initializing SimpleNavigation.config_file_path with empty array (was `nil`
  before). Allows for adding paths before gem has been initialized.

## 2.7.2

* added ability to have more than one config_file_path (useful if
  simple-navigation is used as a part of another gem/plugin). Credits to Luke
  Imhoff.

## 2.7.1

* added SimpleNavigation.request and SimpleNavigation.request_uri as abstraction
  for getting request_uri (rails2/rails3)
* use request.fullpath instead of request.request_uri for Rails3. Credits to Ben
  Langfeld.

## 2.7.0

* added new option :highlights_on to item definition in config-file. Specify a
  regexp which is matched against the current_uri to determine if an item is
  active or not. Replaces explicit highlighting in controllers.
* deprecated explicit highlighting in the controllers.

## 2.6.0

* added rendering option 'skip_if_empty' to Renderer::List to avoid rendering of
  empty ul-tags
* added breadcrumbs renderer incl. specs. A big thanks to Markus Schirp.
* added ability to register a renderer / specify your renderer as symbol in
  render_navigation
* renderer can be specified in render_navigation. Credits to Andi Bade from
  Galaxy Cats.

## 2.5.4

* bugfix: SimpleNavigation.config_file? without params does not check for
  `_navigation.rb` file anymore. Credits to Markus Schirp.

## 2.5.3

* removed deprecated railtie_name from simple_navigation/railtie. Credits to
  Markus Schirp.

## 2.5.2

* added Rails3 generator for navigation_config.rb. Thanks to Josep Jaume Rey.

## 2.5.1

* set template correctly for Rails3 (brings auto highlighting to life again).
  Credits to Josep Jaume Rey.

## 2.5.0

* added new renderer Renderer::Links to simply render the navigation as links
  inside a div.
* also make item.name html_safe (in order you have html_code in the item's
  name). Thanks again, Johan Svensson.

## 2.4.2

* Rails 3.0.0.beta2 compatibility
* Renderer::List --> make content of ul-tag html_safe for rails 3.0.0.beta2 (due
  to rails3 XSS protection). Credits to Johan Svensson and Disha Albaqui.
* updated copyright
* reduced visibility of 'sn_set_navigation' to protected

## 2.4.1

* removing depencency to rails. It installs the newest rails, even if a matching
  version is present. why is that?

## 2.4.0

* added Rails3 compatibility
* added Jeweler::Gemcutter Tasks to Rakefile

## 2.2.3

* changed error handling in config-file. Do not ignore errors in config-file
  anymore.
* only load config-file if it is present. Needed when directly providing items
  in render_navigation.

## 2.2.2

* added lib/simple-navigation.rb to allow 'require simple-navigation' or
  'config.gem "simple-navigation"'

## 2.2.1

* Corrected URL to API-Doc on rubyforge in README

## 2.2.0

* Allow Ranges for :level option. Credits to Ying Tsen Hong.
* Changing the API of `Helpers#render_navigation`. Now supports Ranges for
  `:level` option and :expand_all to render all levels as expanded. Old Api is
  still supported, but deprecated.
* Deprecated `render_all_levels` in config-file.

## 2.1.0

* included Ben Marini's commit which allows individual id-generators.
  Thanks Ben!
* added ability to specify navigation items through items_provider. This is
  useful for generating the navigation dynamically (e.g. from database)
* items can now even be passed directly into render_navigation method.

## 2.0.1

* fixed handling of a non-existent explicit navigation item for a navigation
  context

## 2.0.0

* added auto_highlight feature. Active navigation is determined by comparing
  urls, no need to explicitly set it in the controllers anymore. Thanks to Jack
  Dempsey and Florian Hanke for the support on this.
* added ability to create multi-level navigations (not just limited to primary
  and secondary navigation). Thanks again to Jack Dempsey for the motivation ;-)
* simplified the process to explicitly set the navigation in the controller
  (where needed) - only deepest level has to be specified
* made auto_highlight feature configurable both on global and item_container's
  level
* config file is now evaluated in template if ever possible (not in controller
  anymore)

## 1.4.2

* explicitly loading all source files when requiring 'simple_navigation'.

## 1.4.0

* added the capability to have several navigation-contexts
* doc-fix

## 1.3.1

* now compliant with ruby 1.9.1 (thanks to Gernot Kogler for the feedback)

## 1.3.0

* `render_all_levels` option allows to render all subnavigation independent from
  the active primary navigation ('full open tree'). Userful for javascript
  menus. Thanks to Richard Hulse.
* ability to turn off automatic generation of dom_ids for the list items
  (autogenerate_item_ids). Credits again to Richard Hulse.
* ability to specify dom_class for primary and secondary lists. Thanks Richard!

## 1.2.2

* renderers now have access to request_forgery_protection stuff (this allows
  delete-links as navigation-items)

## 1.2.1

* changed way to include render_*-helper_methods into view (including them into
  Controller and declaring them as helper_methods instead of adding whole module
  as Helper). this seems to be more reliable under certain conditions. Credits
  to Gernot Kogler.

## 1.2.0

* added capability to add conditions to navigation-items
  (`primary.item key, name, url, :if => Proc.new {current_user.admin?}`)

## 1.1.2

* Bugfix: config now gets evaluated on every render_navigation call. Credits to
  Joël Azémar.
* Config file gets reloaded on every render_navigation call in development mode.
  Only load config file on server start in production mode.

## 1.1.1

* Change plugin into a GemPlugin
