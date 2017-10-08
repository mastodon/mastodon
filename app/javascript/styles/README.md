**Once officially adopted, this document should be moved to [Customizing.md](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Customizing.md) !**

# How to make a theme
When creating a custom theme, you should create a new SCSS in a directory with the same name as your custom theme.

Example: Create a theme "foo"
```
style
├custom
│└custom.scss
├default
├foo
│└variables.scss
├theme-default.scss
└theme-foo.scss
```
In this case, "theme-foo.scss" will be as follows:
```
@import 'default/mixins';
@import 'foo/variables'; /*foo theme*/
@import 'default/fonts/roboto';
@import 'default/fonts/roboto-mono';
@import 'default/fonts/montserrat';

@import 'default/reset';
@import 'default/basics';
@import 'default/containers';
@import 'default/lists';
@import 'default/footer';
@import 'default/compact_header';
@import 'default/landing_strip';
@import 'default/forms';
@import 'default/accounts';
@import 'default/stream_entries';
@import 'default/components';
@import 'default/emoji_picker';
@import 'default/about';
@import 'default/tables';
@import 'default/admin';
@import 'default/rtl';

@import 'custom/custom';
```

When the theme is completed, describe it in "config/themes.yml" as below:

```
default: styles/theme_default.scss
foo: styles/theme_foo.scss
```