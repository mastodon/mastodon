Tips for app developers
=======================

## Authentication

Make sure that you allow your users to specify the domain they want to connect to before login. Use that domain to acquire a client id/secret for OAuth2 and then proceed with normal OAuth2 also using that domain to build the URLs.

In my opinion it is easier for people to understand what is being asked of them if you ask for a `username@domain` type input, since it looks like an e-mail address. Though the username part is not required for anything in the OAuth2 process. Once the user is logged in, you get information about the logged in user from `/api/v1/accounts/verify_credentials`

## Usernames

Make sure that you make it possible to see the `acct` of any user in your app (since it includes the domain part for remote users), people must be able to tell apart users from different domains with the same username.

## Formatting

The API delivers already formatted HTML to your app. This isn't ideal since not all apps are based on HTML, but this is not fixable as it's part of the way OStatus federation works. Most importantly, you get some information on linked entities alongside the HTML of the status body. For example, you get a list of mentioned users, and a list of media attachments, and a list of hashtags. It is possible to convert the HTML to whatever you need in your app by parsing the HTML tags and matching their `href`s to the linked entities. If a match cannot be found, the link must stay a clickable link.
