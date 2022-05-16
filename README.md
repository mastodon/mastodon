![decodon_logo_full](https://user-images.githubusercontent.com/382669/168650458-7d1620ee-9411-4d96-8786-8d1a342dbd71.png)

## Decodon

An opinionated fork of mastodon with the following modifications:

* All accounts are locked/private, meaning content is only distributed to followers [jesseplusplus/decodon#1](https://github.com/jesseplusplus/decodon/pull/1)

* Support for push notifications to Expo-based apps [jesseplusplus/decodon#2](https://github.com/jesseplusplus/decodon/pull/2)

* Pre-signed URLs for extra-secure storage of uploaded private media [jesseplusplus/decodon#9](https://github.com/jesseplusplus/decodon/pull/9)

* replies are treated more like comments and are filtered from the home feed [jesseplusplus/decodon#3](https://github.com/jesseplusplus/decodon/pull/3)

* circles (lists of followers you can address posts to instead of only followers) - cherry-picked from [fedibird](https://github.com/fedibird/fedibird) - [jesseplusplus/decodon#13](https://github.com/jesseplusplus/decodon/pull/13)

* default "inner circle" for all accounts to get them started - [jesseplusplus/decodon#14](https://github.com/jesseplusplus/decodon/pull/14)

* more control over logo and branding in email templates [jesseplusplus/decodon#10](https://github.com/jesseplusplus/decodon/pull/10)

* updated heroku deployment configs

## Use

Please feel free to run your own decodon server if all of the above features appeal to you, or to cherry-pick any changes you'd like to your own fork. Right now none of these features are optional or configurable.

## License

Copyright (C) 2016-2021 Eugen Rochko & other Mastodon contributors (see [AUTHORS.md](AUTHORS.md))

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
