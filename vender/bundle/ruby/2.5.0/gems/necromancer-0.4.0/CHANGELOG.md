# Change log

## [v0.4.0] - 2017-02-18

### Added
* Add :string -> :time conversion
* Add inspection methods to Context and ConversionTarget
* Add module level Necromancer#convert for convenience and more functional style
* Add ConversionTarget#>> call for functional style converions

### Changed
* Change fail to raise in ConversionTarget#for
* Change fail to raise in Conversions
* Change ConversionTarget#detect to handle Class type coercion

### Fixed
* Fix bug with type detection
* Fix Ruby 2.4.0 warning about Fixnum & Bignum type

## [v0.3.0] - 2014-12-14

### Added
* Add array converters for :hash, :set and :object conversions
* Add ability to configure global conversion settings per instance

## [v0.2.0] - 2014-12-07

### Added
* Add #fail_conversion_type to Converter and use in converters
* Add DateTimeConverters
* Add string to numeric type conversion

### Changed
* Change IntegerConverters & FloatConverters into Numeric Converters

## [v0.1.0] - 2014-11-30

* Initial implementation and release

[v0.4.0]: https://github.com/piotrmurach/necromancer/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/piotrmurach/necromancer/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/piotrmurach/necromancer/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/piotrmurach/necromancer/compare/v0.1.0
