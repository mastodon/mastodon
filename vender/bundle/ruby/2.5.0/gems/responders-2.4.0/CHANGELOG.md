## 2.4.0

* `respond_with` now accepts a new kwargs called `:render` which goes straight to the `render`
   call after an unsuccessful post request. Usefull if for example you need to render a template
   which is outside of controller's path eg:

   `respond_with resource, render: { template: 'path/to/template' }`

## 2.3.0

* `verify_request_format!` is aliased to `verify_requested_format!` now.
* Implementing the `interpolation_options` method on your controller is deprecated
  in favor of naming it `flash_interpolation_options` instead.

## 2.2.0

* Added the `verify_request_format!` method, that can be used as a `before_action`
  callback to prevent your actions from being invoked when the controller does
  not respond to the request mime type, preventing the execution of complex
  queries or creating/deleting records from your app.

## 2.1.2

* Fix rendering when using `ActionController::API`. (by @eLod)
* Added API controller template for the controller generator. (by @vestimir)

## 2.1.1

* Added support for Rails 5.

## 2.1.0

* No longer automatically set the responders generator as many projects may use this gem as a dependency. When upgrading, users will need to add `config.app_generators.scaffold_controller :responders_controller` to their application. The `responders:install` generator has been updated to automatically insert it in new applications

## 2.0.1

* Require `rails/railtie` explicitly before using it
* Require `action_controller` explicitly before using it
* Remove unnecessary and limiting `resourceful?` check that required models to implement `to_#{format}` (such checks are responsibility of the rendering layer)

## 2.0.0

* Import `respond_with` and class-level `respond_to` from Rails
* Support only Rails ~> 4.2
* `Responders::LocationResponder` is now included by the default responder (and therefore deprecated)

## 1.1.0

* Support Rails 4.1.
* Allow callable objects as the location.

## 1.0.0

* Improve controller generator to work closer to the Rails 4 one, and make it
  compatible with strong parameters.
* Drop support for Rails 3.1 and Ruby 1.8, keep support for Rails 3.2
* Support for Rails 4.0 onward
* Fix flash message on destroy failure. Fixes #61

## 0.9.3

* Fix url generation for namespaced models

## 0.9.2

* Properly inflect custom responders names

## 0.9.1

* Fix bug with namespace lookup

## 0.9.0

* Disable namespace lookup by default

## 0.8

* Allow embedded HTML in flash messages

## 0.7

* Support Rails 3.1 onward
* Support namespaced engines

## 0.6

* Allow engine detection in generators
* HTTP Cache is no longer triggered for collections
* `:js` now sets the `flash.now` by default, instead of `flash`
* Renamed `responders_install` generator to `responders:install`
* Added `CollectionResponder` which allows you to always redirect to the collection path
  (index action) after POST/PUT/DELETE

## 0.5

* Added Railtie and better Rails 3 support
* Added `:flash_now` as option

## 0.4

* Added `Responders::FlashResponder.flash_keys` and default to `[ :notice, :alert ]`
* Added support to `respond_with(@resource, :notice => "Yes!", :alert => "No!")``

## 0.1

* Added `FlashResponder`
* Added `HttpCacheResponder`
* Added responders generators
