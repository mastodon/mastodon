# Hellō Patches

## HELLO_PATCH(1): use nickname instead of uid for username

The same claim is used to map both the user id and the username, this claim is configured through the `OIDC_UID_FIELD`
environment variable.

Ideally there should be two different environment vars, and the user id by default should be mapped to `sub`.

For now the username is hard coded to `nickname`. This should be changed to `preferred_username` when that claim
becomes available.

## HELLO_PATCH(2) use OIDC for Sign-Up

Instead of showing the Sign-Up form start the OpenID Connect authorization request.

The request starts at `/auth/auth/openid_connect` and it must be a POST request. The `data-method="post"` attribute on
the `<a>` tag enforces that.
