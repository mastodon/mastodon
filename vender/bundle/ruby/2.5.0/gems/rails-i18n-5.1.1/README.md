Rails Locale Data Repository
============================

[![Gem Version](https://badge.fury.io/rb/rails-i18n.svg)](http://badge.fury.io/rb/rails-i18n)
[![Build Status](https://secure.travis-ci.org/svenfuchs/rails-i18n.png)](http://travis-ci.org/svenfuchs/rails-i18n)

Central point to collect locale data for use in Ruby on Rails.

## Gem installation

Add to your Gemfile:

    gem 'rails-i18n', '~> 5.1' # For 5.0.x, 5.1.x and 5.2.x
    gem 'rails-i18n', '~> 4.0' # For 4.0.x
    gem 'rails-i18n', '~> 3.0' # For 3.x
    gem 'rails-i18n', github: 'svenfuchs/rails-i18n', branch: 'master' # For 5.x
    gem 'rails-i18n', github: 'svenfuchs/rails-i18n', branch: 'rails-4-x' # For 4.x
    gem 'rails-i18n', github: 'svenfuchs/rails-i18n', branch: 'rails-3-x' # For 3.x

or run this command:

    gem install rails-i18n -v '~> 5.1' # For  For 5.0.x, 5.1.x and 5.2.x
    gem install rails-i18n -v '~> 4.0' # For 4.0.x
    gem install rails-i18n -v '~> 3.0' # For 3.x

Note that your rails version must be 3.0 or higher if you want to install `rails-i18n` as a gem. For rails 2.x, install it manually as described below.

## Configuration

By default `rails-i18n` loads all locale files, pluralization and
transliteration rules available in the gem. This behaviour can be changed, if you
specify in `config/environments/*` the locales which have to be loaded via
`I18n.available_locales` option:

    config.i18n.available_locales = ['es-CO', :de]

or

    config.i18n.available_locales = :nl

## Manual installation

Download the locale files that are found in the directory [rails/locale](http://github.com/svenfuchs/rails-i18n/tree/master/rails/locale/) and put them into the `config/locales` directory of your Rails application.

If any translation doesn't suit well to the requirements of your application, edit them or add your own locale files.

For more information, visit [Rails Internationalization (I18n) API](http://guides.rubyonrails.org/i18n.html) on the _RailsGuides._

## Usage on Rails 2.3

Locale data whose structure is compatible with Rails 2.3 are available on the separate branch [rails-2-3](https://github.com/svenfuchs/rails-i18n/tree/rails-2-3).

## Available Locales

Available locales are:

> af, ar, az, be, bg, bn, bs, ca, cs, cy, da, de, de-AT, de-CH, de-DE, el, el-CY,
> en, en-AU, en-CA, en-GB, en-IE, en-IN, en-NZ, en-US, en-ZA, en-CY,eo, es,
> es-419, es-AR, es-CL, es-CO, es-CR, es-EC, es-ES, es-MX, es-NI, es-PA, es-PE, es-US, es-VE,
> et, eu, fa, fi, fr, fr-CA, fr-CH, fr-FR, gl, he, hi, hi-IN, hr, hu, id, is, it,
> it-CH, ja, ka, km, kn, ko, lb, lo, lt, lv, mk, ml, mn, mr-IN, ms, nb, ne, nl, nn, or,
> pa, pl, pt, pt-BR, rm, ro, ru, sk, sl, sq, sr, sw, ta, th, tl, tr, tt, ug,
> ur, uz, vi, wo, zh-CN, zh-HK, zh-TW, zh-YUE

Complete locales are:

> af, da, de, de-AT, de-CH, de-DE, en-US, es, es-419, es-AR, es-CL, es-CO, es-CR, es-EC,
> es-ES, es-MX, es-NI, es-PA, es-PE, es-US, es-VE, et, fa, fr, fr-CA, fr-CH, fr-FR, id, ja, ka, ml, nb,
> nl, nn, pt-BR, sv, sv-SE, tr, zh-CN, zh-HK, zh-TW, zh-YUE, uk

Currently, most locales are incomplete. Typically they lack the following keys:

- `activerecord.errors.messages.record_invalid`
- `activerecord.errors.messages.restrict_dependent_destroy.has_one`
- `activerecord.errors.messages.restrict_dependent_destroy.has_many`
- `errors.messages.model_invalid`
- `errors.messages.required`

We always welcome your contributions!

## Currency symbols

Some locales have the symbol of the currency (e.g. `€`) under the key `number.currency.format.unit`,
while others have the code (e.g. `CHF`). The value of the key depends on the widespread adoption of
the unicode currency symbols by fonts.

For example the Turkish Lira sign (`₺`) was recently added in Unicode 6.2 and while most popular
fonts have a glyph, there are still many fonts that will not render the character correctly.

If you want to provide a different value, in a Rails app, you can create your own locale file under
`config/locales/tr.yml` and override the respective key:

```YAML
tr:
  number:
    currency:
      format:
        unit: TL
```

## How to contribute

### Quick contribution

If you are familiar with GitHub operations, follow the procedures described in the subsequent sections.

If you are not,

* Save your locale data on the [Gist](http://gist.github.com).
* Open an issue with reference to the Gist you created.

### Fetch the `rails-i18n` repository

* Get a github account and Git program if you haven't. See [Help.Github](http://help.github.com/) for instructions.
* Fork `svenfuchs/rails-i18n` repository and clone it into your PC.

### Create or edit your locale file

* Have a look in `rails/locale/en.yml`, which should be used as the base of your translation.
* Create or edit your locale file.
  Please pay attention to save your files as UTF-8.

### Test your locale file

Before committing and pushing your changes, test the integrity of your locale file.

    bundle exec rake spec

Make sure you have included all translations with:

    bundle exec rake i18n-spec:completeness rails/locale/en.yml rails/locale/YOUR_NEW_LOCALE.yml

You can list all complete and incomplete locales:

    thor locales:complete
    thor locales:incomplete

Also, you can list all available locales:

    thor locales:list

You can list all missing keys:

    i18n-tasks missing es

### Edit README.md

Add your locale name to the list in `README.md` if it isn't there.

### Send pull request

If you are ready, push the repository into the Github and send us a pull request.

We will do the formality check and publish it as quick as we can.

## See also

* [devise-i18n](https://github.com/tigrish/devise-i18n)
* [will-paginate-i18n](https://github.com/tigrish/will-paginate-i18n)
* [kaminari-i18n](https://github.com/tigrish/kaminari-i18n)
* [i18n-country-translation](https://github.com/onomojo/i18n-country-translations) for translations of country names
* [i18n-spec](https://github.com/tigrish/i18n-spec) for RSpec matchers to test your locale files
* [iso](https://github.com/tigrish/iso) for the list of valid language/region codes and their translations
* [i18n-tasks](https://github.com/glebm/i18n-tasks)

## License

[MIT](https://github.com/svenfuchs/rails-i18n/blob/master/MIT-LICENSE.txt)

## Contributors

See [https://github.com/svenfuchs/rails-i18n/contributors](https://github.com/svenfuchs/rails-i18n/contributors)

## Special thanks

[Tsutomu Kuroda](https://github.com/kuroda) for untiringly taking care of this repository, issues and pull requests
