OAuth details
=============

We use the [Doorkeeper gem for OAuth](https://github.com/doorkeeper-gem/doorkeeper/wiki), so you can refer to their docs on specifics of the end-points.

The API is divided up into access scopes:

- `read`: Read data
- `write`: Post statuses and upload media for statuses
- `follow`: Follow, unfollow, block, unblock

Multiple scopes can be requested during the authorization phase with the `scope` query param (space-separate the scopes). If you do not specify a `scope` in your authorization request, the resulting access token will default to `read` access.
