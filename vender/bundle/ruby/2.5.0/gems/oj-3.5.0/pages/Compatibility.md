# Compatibility

**Ruby**

Oj is compatible with Ruby 2.0.0, 2.1, 2.2, 2.3, 2.4 and RBX.
Support for JRuby has been removed as JRuby no longer supports C extensions and
there are bugs in the older versions that are not being fixed.

**Rails**

Although up until 4.1 Rails uses [multi_json](https://github.com/intridea/multi_json), an [issue in Rails](https://github.com/rails/rails/issues/9212) causes ActiveSupport to fail to make use Oj for JSON handling.
There is a
[gem to patch this](https://github.com/GoodLife/rails-patch-json-encode) for
Rails 3.2 and 4.0. As of the Oj 2.6.0 release the default behavior is to not use
the `to_json()` method unless the `:use_to_json` option is set. This provides
another work around to the rails older and newer behavior.

The latest ActiveRecord is able to work with Oj by simply using the line:

```
serialize :metadata, Oj
```

In version Rails 4.1, multi_json has been removed, and this patch is unnecessary and will no longer work.
See {file:Rails.md}.
