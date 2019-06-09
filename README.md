Florence Mastodon
=================

Mastodon is a **free, open-source social network server** based on ActivityPub. This is *not* the
official version of Mastodon; this is a separate version (i.e. a fork) maintained by Florence. For
more information on Mastodon, you can see the [official website] and the [upstream repo].

[official website]: https://joinmastodon.org
[upstream repo]: https://github.com/tootsuite/mastodon

This version of Mastodon will include much-wanted changes by the community that are not included
in the upstream version of Mastodon. Migrating from the lastest stable release of Mastodon to
Florence's Mastodon will always be possible, to ensure that everyone can benefit from these
changes.

## Versioning

Florence Mastodon will follow [semantic versioning]. Essentially, this means that versions will be
MAJOR.MINOR.PATCH, where:

* MAJOR version bumps indicate fundamentally incompatible changes. This includes major UI changes,
  changes to how servers federate, changes that may break existing apps, etc.
* MINOR version bumps indicate new features that don't break backwards compatibility. While it
  won't explicitly break anything, users may have to go out of their way to use the new feature,
  and apps may have to explicitly add support for the feature.
* PATCH version bumps are for fixes that don't add any new features.

[semantic versioning]: https://semver.org

Because Florence Mastodon is currently less than version 1.0.0, there won't be any PATCH versions,
and versions will be of the form 0.MAJOR.MINOR. This basically means that breaking changes can
happen often.

## Release timeline

Florence Mastodon 0.0.0 is mostly equivalent to Mastodon 2.7.1, with some extra changes added in.
Right now, the goal pre-1.0 is to incorporate existing, already-developed changes into the fork so
that people have a central version to upgrade to.

1.0.0 will be equivalent to some future, stable release of Mastodon, plus these changes. This could
be 2.8 or 2.9 or even 2.10; it depends on how fast development happens. Once this is done, work on
new features, plus refinement of existing, larger features (such as Glitch.Social's theme changes)
can start.

Be sure to check out the issues on the repository for details!

## License

Copyright (C) 2016-2019 Florence, Eugen Rochko, and many other Mastodon contributors; see [AUTHORS.md](AUTHORS.md).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
