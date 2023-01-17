# Hellō Patches

## HELLO_PATCH(1): use preferred_username instead of uid for username

The same claim is used to map both the user id and the username, this claim is configured through the `OIDC_UID_FIELD`
environment variable.

Ideally there should be two different environment vars, and the user id by default should be mapped to `sub`.

The username is hard coded to `preferred_username`.


## HELLO_PATCH(2) use OIDC for Sign-Up

Instead of showing the actual Sign-Up form only show a "Continue with Hellō" button that starts the OpenID Connect
authorization request.

The request starts at `/auth/auth/openid_connect` and it must be a POST request.


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


## HELLO_PATCH(7) remove "Display name" on profile page


## HELLO_PATCH(8) add "Mastodon Builder" button at the top of the profile page

Added button labelled "Mastodon Builder" with link to https://wallet.hello.coop/mastodon at the top of the profile page.


## HELLO_PATCH(9) remove Security section on Account settings page (/auth/edit)

This removes the email and password editing functionality.

Should revisit for a more nuanced approach, should probably enable for admin account(s) and/or accounts that do have a
password set.

The method to revisit is `use_seamless_external_login?`. Currently this method returns `true` only for PAM and LDAP
authentication, disconnected from the similar `omniauth_only?`


## HELLO_PATCH(10): append the :verified: emoji to the end of the display name


## HELLO_PATCH(11): hide username and password login form

Overriding the `omniauth_only?` methods (or setting the `OMNIAUTH_ONLY` env var) also disables registration, and while
the  registration flow uses OpenID Connect it does rely on showing the server rules which is part of the registration
flow. So the patch is done performed only in the view.

Also:
* hide "Login with" if username and password form not available
* change "or Login with" to "or"
* change the login button label to "Login with Hellō"


## HELLO_PATCH(12): hide the "Two-factor Auth" menu entry

Visiting `/settings/otp_authentication` still works.


## HELLO_PATCH(13) log frontend analytics events

Log analytics requests


## HELLO_PATCH(14) Hellō specific metadata

Add Hellō version and issuer to the output of the `/nodeinfo/2.0` endpoint.


## HELLO_PATCH(15) remove most navigation links at bottom of auth pages


## HELLO_PATCH(16) change Sign-Up "Accept" button label to "Continue with Hellō"


## HELLO_PATCH(17) move Bio below the card

On the "Edit profile" page (`/settings/profile`) move the Bio (aka Note) below the account card (header, avatar & username card)
