Testing the API with cURL
=========================

Mastodon builds around the idea of being a server first, rather than a client itself. Similarly to how a XMPP chat server communicates with others and with its own clients, Mastodon takes care of federation to other networks, like other Mastodon or GNU Social instances. So Mastodon provides a REST API, and a 3rd-party app system for using it via OAuth2.

You can get a client ID and client secret required for OAuth [via an API end-point](API.md#apps).

From these two, you will need to acquire an access token. It is possible to do using your account's e-mail and password like this:

    curl -X POST -d "client_id=CLIENT_ID_HERE&client_secret=CLIENT_SECRET_HERE&grant_type=password&username=YOUR_EMAIL&password=YOUR_PASSWORD" -Ss https://mastodon.social/oauth/token

The `/oauth/token` path will attempt to login with the given credentials, and then retrieve the access token for the current user. If the login failed the response will be a 302 redirect to `/auth/sign_in`. Otherwise the response will be a JSON object containing the key `access_token`.

Use that token in any API requests by setting a header like this:

    curl --header "Authorization: Bearer ACCESS_TOKEN_HERE" -sS https://mastodon.social/api/v1/timelines/home

Please note that the password-based approach is not recommended especially if you're dealing with other user's accounts and not just your own. Usually you would use the authorization grant approach where you redirect the user to a web page on the original site where they can login and authorize the application and are then redirected back to your application with an access code.
