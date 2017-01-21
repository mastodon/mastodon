# Contents

- [Available libraries](#available-libraries)
- [Notes](#notes)
- [Methods](#methods)
  - Posting a status
  - Uploading media
  - Retrieving a timeline
  - Retrieving notifications
  - Following a remote user
  - Fetching data
  - Deleting a status
  - Reblogging a status
  - Favouriting a status
  - Threads (status context)
  - Who reblogged/favourited a status
  - Following/unfollowing accounts
  - Blocking/unblocking accounts
  - Creating OAuth apps
- [Entities](#entities)
  - Status
  - Account
- [Pagination](#pagination)

# Available libraries

- [For Ruby](https://github.com/tootsuite/mastodon-api)
- [For Python](https://github.com/halcy/Mastodon.py)
- [For JavaScript](https://github.com/Zatnosk/libodonjs)
- [For JavaScript (Node.js)](https://github.com/jessicahayley/node-mastodon)

# Notes

When an array parameter is mentioned, the Rails convention of specifying array parameters in query strings is meant. For example, a ruby array like `foo = [1, 2, 3]` can be encoded in the params as `foo[]=1&foo[]=2&foo[]=3`. Square brackets can be indexed but can also be empty.

When a file parameter is mentioned, a form-encoded upload is expected.

# Methods
## Posting a new status

**POST /api/v1/statuses**

Form data:

- `status`: The text of the status
- `in_reply_to_id` (optional): local ID of the status you want to reply to
- `media_ids` (optional): array of media IDs to attach to the status (maximum 4)
- `sensitive` (optional): set this to mark the media of the status as NSFW
- `visibility` (optional): either `private`, `unlisted` or `public`

Returns the new status.

**POST /api/v1/media**

Form data:

- `file`: Image to be uploaded

Returns a media object with an ID that can be attached when creating a status (see above).

## Retrieving a timeline

**GET /api/v1/timelines/home**
**GET /api/v1/timelines/mentions**
**GET /api/v1/timelines/public**
**GET /api/v1/timelines/tag/:hashtag**

Returns statuses, most recent ones first. Home timeline is statuses from people you follow, mentions timeline is all statuses that mention you. Public timeline is "whole known network", and the last is the hashtag timeline.

Query parameters:

- `max_id` (optional): Skip statuses younger than ID (e.g. navigate backwards in time)
- `since_id` (optional): Skip statuses older than ID (e.g. check for updates)

## Notifications

**GET /api/v1/notifications**

Returns notifications for the authenticated user. Each notification has an `id`, a `type` (mention, reblog, favourite, follow), an `account` which it came *from*, and in case of mention, reblog and favourite also a `status`.

## Following a remote user

**POST /api/v1/follows**

Form data:

- uri: username@domain of the person you want to follow

Returns the local representation of the followed account.

## Fetching data

**GET /api/v1/statuses/:id**

Returns status.

**GET /api/v1/accounts/:id**

Returns account.

**GET /api/v1/accounts/verify_credentials**

Returns authenticated user's account.

**GET /api/v1/accounts/:id/statuses**

Returns statuses by user. Same options as timeline are permitted.

**GET /api/v1/accounts/:id/following**

Returns users the given user is following.

**GET /api/v1/accounts/:id/followers**

Returns users the given user is followed by.

**GET /api/v1/accounts/relationships**

Returns relationships (`following`, `followed_by`, `blocking`) of the current user to a list of given accounts.

Query parameters:

- `id` (can be array): Account IDs

**GET /api/v1/accounts/search**

Returns matching accounts. Will lookup an account remotely if the search term is in the username@domain format and not yet in the database.

Query parameters:

- `q`: what to search for
- `limit`: maximum number of matching accounts to return

**GET /api/v1/blocks**

Returns accounts blocked by authenticated user.

**GET /api/v1/favourites**

Returns statuses favourited by authenticated user.

## Deleting a status

**DELETE /api/v1/statuses/:id**

Returns an empty object.

## Reblogging a status

**POST /api/v1/statuses/:id/reblog**

Returns a new status that wraps around the reblogged one.

## Unreblogging a status

**POST /api/v1/statuses/:id/unreblog**

Returns the status that used to be reblogged.

## Favouriting a status

**POST /api/v1/statuses/:id/favourite**

Returns the target status.

## Unfavouriting a status

**POST /api/v1/statuses/:id/unfavourite**

Returns the target status.

## Threads

**GET /api/v1/statuses/:id/context**

Returns `ancestors` and `descendants` of the status.

## Who reblogged/favourited a status

**GET /api/v1/statuses/:id/reblogged_by**
**GET /api/v1/statuses/:id/favourited_by**

Returns list of accounts.

## Following and unfollowing users

**POST /api/v1/accounts/:id/follow**
**POST /api/v1/accounts/:id/unfollow**

Returns the updated relationship to the user.

## Blocking and unblocking users

**POST /api/v1/accounts/:id/block**
**POST /api/v1/accounts/:id/unblock**

Returns the updated relationship to the user.

## OAuth apps

**POST /api/v1/apps**

Form data:

- `client_name`: Name of your application
- `redirect_uris`: Where the user should be redirected after authorization (for no redirect, use `urn:ietf:wg:oauth:2.0:oob`)
- `scopes`: This can be a space-separated list of the following items: "read", "write" and "follow" (see [this page](OAuth-details.md) for details on what the scopes do)
- `website`: (optional) URL to the homepage of your app

Creates a new OAuth app. Returns `id`, `client_id` and `client_secret` which can be used with [OAuth authentication in your 3rd party app](Testing-with-cURL.md).

___

# Entities

## Status

| Attribute           | Description |
|---------------------|-------------|
| `id`                ||
| `uri`               | fediverse-unique resource ID |
| `url`               | URL to the status page (can be remote) |
| `account`           | Account |
| `in_reply_to_id`    | null or ID of status it replies to |
| `reblog`            | null or Status|
| `content`           | Body of the status. This will contain HTML (remote HTML already sanitized) |
| `created_at`        ||
| `reblogs_count`     ||
| `favourites_count`  ||
| `reblogged`         | Boolean for authenticated user |
| `favourited`        | Boolean for authenticated user |
| `media_attachments` | array of MediaAttachments |
| `mentions`          | array of Mentions |
| `application`       | Application from which the status was posted |

Media Attachment:

| Attribute           | Description |
|---------------------|-------------|
| `url`               | URL of the original image (can be remote) |
| `preview_url`       | URL of the preview image |
| `type`              | Image or video |

Mention:

| Attribute           | Description |
|---------------------|-------------|
| `url`               | URL of user's profile (can be remote) |
| `acct`              | Username for local or username@domain for remote users |
| `id`                | Account ID |

Application:

| Attribute           | Description |
|---------------------|-------------|
| `name`              | Name of the app |
| `website`           | Homepage URL of the app |

## Account

| Attribute         | Description |
|-------------------|-------------|
| `id`              ||
| `username`        ||
| `acct`            | Equals username for local users, includes @domain for remote ones |
| `display_name`    ||
| `note`            | Biography of user |
| `url`             | URL of the user's profile page (can be remote) |
| `avatar`          | URL to the avatar image |
| `header`          | URL to the header image |
| `followers_count` ||
| `following_count` ||
| `statuses_count`  ||

# Pagination

API methods that return collections of items can return a `Link` header containing URLs for the `next` and `prev` pages. [Link header RFC](https://tools.ietf.org/html/rfc5988)
