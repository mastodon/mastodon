# Hellō Patches

## HELLO_PATCH(1): use nickname instead of uid for username

The same claim is used to map both the user id and the username, this claim is configured through the `OIDC_UID_FIELD`
environment variable.

Ideally there should be two different environment vars, and the user id by default should be mapped to `sub`.

For now the username is hard coded to `nickname`. This should be changed to `preferred_username` when that claim
becomes available.

How is `nickname` retrieved:

* `auth.extra.raw_info.nickname` has the raw parsed Id Token
* `auth.info.nickname` currently is `nil`, seems to map `preferred_username`, TBD when that claim becomes available


## HELLO_PATCH(2) use OIDC for Sign-Up

Instead of showing the Sign-Up form start the OpenID Connect authorization request.

The request starts at `/auth/auth/openid_connect` and it must be a POST request. The `data-method="post"` attribute on
the `<a>` tag enforces that.


## HELLO_PATCH(3) enable auto-loading in development

By default auto-loading is disabled. For code changes to be reloaded you have to drop into rails console and run
`reload!`.

Everything under `app/*` is now set for auto-load.

In rails console you can check the auto-reload status with:
```ruby
Rails.application.config.autoload_paths
```


## HELLO_PATCH(4) Explicitly create user if not found

Looking up an user is mixed in with creating the User and associated Identity. Make the user creation explicit, so we
can take a different action on user creation versus user sign-in.


## HELLO_PATCH(5) redirect to Hellō Mastodon verifier after registration

Redirect only on user creation.


## HELLO_PATCH(6) use Hello specific Sign In Banner

No link to `/auth/sign_in` with username and password form and OIDC button, directly render button that initiates 
"Sign in with Hello".

Username and password form still accessible at `/auth/sign_in`.
