# Hellō Patches

## HELLO_PATCH(1): use nickname instead of uid for username

The same claim is used to map both the user id and the username, this claim is configured through the `OIDC_UID_FIELD`
environment variable.

Ideally there should be two different environment vars, and the user id by default should be mapped to `sub`.

For now the username is hard coded to `nickname`. This should be changed to `preferred_username` when that claim
becomes available.

