# Pundit

## 1.1.0 (2016-01-14)

- Can retrieve policies via an array of symbols/objects.
- Add autodetection of param key to `permitted_attributes` helper.
- Hide some methods which should not be actions.
- Permitted attributes should be expanded.
- Generator uses `RSpec.describe` according to modern best practices.

## 1.0.1 (2015-05-27)

- Fixed a regression where NotAuthorizedError could not be ininitialized with a string.
- Use `camelize` instead of `classify` for symbol policies to prevent weird pluralizations.

## 1.0.0 (2015-04-19)

- Caches policy scopes and policies.
- Explicitly setting the policy for the controller via `controller.policy = foo` has been removed. Instead use `controller.policies[record] = foo`.
- Explicitly setting the policy scope for the controller via `controller.policy_policy = foo` has been removed. Instead use `controller.policy_scopes[scope] = foo`.
- Add `permitted_attributes` helper to fetch attributes from policy.
- Add `pundit_policy_authorized?` and `pundit_policy_scoped?` methods.
- Instance variables are prefixed to avoid collisions.
- Add `Pundit.authorize` method.
- Add `skip_authorization` and `skip_policy_scope` helpers.
- Better errors when checking multiple permissions in RSpec tests.
- Better errors in case `nil` is passed to `policy` or `policy_scope`.
- Use `inspect` when printing object for better errors.
- Dropped official support for Ruby 1.9.3

## 0.3.0 (2014-08-22)

- Extend the default `ApplicationPolicy` with an `ApplicationPolicy::Scope` (#120)
- Fix RSpec 3 deprecation warnings for built-in matchers (#162)
- Generate blank policy spec/test files for Rspec/MiniTest/Test::Unit in Rails (#138)

## 0.2.3 (2014-04-06)

- Customizable error messages: `#query`, `#record` and `#policy` methods on `Pundit::NotAuthorizedError` (#114)
- Raise a different `Pundit::AuthorizationNotPerformedError` when `authorize` call is expected in controller action but missing (#109)
- Update Rspec matchers for Rspec 3 (#124)

## 0.2.2 (2014-02-07)

- Customize the user to be passed into policies: `pundit_user` (#42)
