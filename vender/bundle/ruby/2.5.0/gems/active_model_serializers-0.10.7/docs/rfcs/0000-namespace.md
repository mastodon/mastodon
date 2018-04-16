- Start Date: (2015-10-29)
- RFC PR: https://github.com/rails-api/active_model_serializers/pull/1310
- ActiveModelSerializers Issue: https://github.com/rails-api/active_model_serializers/issues/1298

# Summary

Provide a consistent API for the user of the AMS.

# Motivation

The actual public API is defined under `ActiveModelSerializers`,
`ActiveModel::Serializer` and `ActiveModel`.

At the `ActiveModel::Serializer` we have:

- `ActiveModel::Serializer.config`
- `ActiveModel::Serializer`

At the `ActiveModelSerializers` we have:

- `ActiveModelSerializers::Model`
- `ActiveModelSerializers.logger`

At `ActiveModel` we have:

- `ActiveModel::SerializableResource`

The idea here is to provide a single namespace `ActiveModelSerializers` to the user.
Following the same idea we have on other gems like
[Devise](https://github.com/plataformatec/devise/blob/e9c82472ffe7c43a448945f77e034a0e47dde0bb/lib/devise.rb),
[Refile](https://github.com/refile/refile/blob/6b24c293d044862dafbf1bfa4606672a64903aa2/lib/refile.rb) and
[Active Job](https://github.com/rails/rails/blob/30bacc26f8f258b39e12f63fe52389a968d9c1ea/activejob/lib/active_job.rb)
for example.

This way we are clarifing the boundaries of
[ActiveModelSerializers and Rails](https://github.com/rails-api/active_model_serializers/blob/master/CHANGELOG.md#prehistory)
and make clear that the `ActiveModel::Serializer` class is no longer the primary
behavior of the ActiveModelSerializers.

# Detailed design

## New classes and modules organization

Since this will be a big change we can do this on baby steps, read small pull requests. A
possible approach is:

- All new code will be in `lib/active_model_serializers/` using
  the module namespace `ActiveModelSerializers`.
- Move all content under `ActiveModel::Serializer` to be under
  `ActiveModelSerializers`, the adapter is on this steps;
- Move all content under `ActiveModel` to be under `ActiveModelSerializers`,
  the `SerializableResource` is on this step;
- Change all public API that doesn't make sense, keeping in mind only to keep
  this in the same namespace
- Update the README;
- Update the docs;

The following table represents the current and the desired classes and modules
at the first moment.

| Current                                                | Desired                                          | Notes              |
|--------------------------------------------------------|--------------------------------------------------|--------------------|
| `ActiveModelSerializers` and `ActiveModel::Serializer` | `ActiveModelSerializers`                         | The main namespace |
| `ActiveModelSerializers.logger`                        | `ActiveModelSerializers.logger`                  ||
| `ActiveModelSerializers::Model`                        | `ActiveModelSerializers::Model`                  ||
| `ActiveModel::SerializableResource`                    | `ActiveModelSerializers::SerializableResource`   ||
| `ActiveModel::Serializer`                              | `ActiveModelSerializers::Serializer`             | The name can be discussed in a future pull request. For example, we can rename this to `Resource` [following this idea](https://github.com/rails-api/active_model_serializers/pull/1301/files#r42963185) more info about naming in the next section|
| `ActiveModel::Serializer.config`                       | `ActiveModelSerializers.config`                ||

## Renaming of class and modules

When moving some content to the new namespace we can find some names that does
not make much sense like `ActiveModel::Serializer::Adapter::JsonApi`.
Discussion of renaming existing classes / modules and JsonApi objects will
happen in separate pull requests, and issues, and in the google doc
https://docs.google.com/document/d/1rcrJr0sVcazY2Opd_6Kmv1iIwuHbI84s1P_NzFn-05c/edit?usp=sharing

Some of names already have a definition.

- Adapters get their own namespace under ActiveModelSerializers. E.g
  `ActiveModelSerializers::Adapter`
- Serializers get their own namespace under ActiveModelSerializers. E.g
  `ActiveModelSerializers::Serializer`

## Keeping compatibility

All moved classes or modules be aliased to their old name and location with
deprecation warnings, such as
[was done for CollectionSerializer](https://github.com/rails-api/active_model_serializers/pull/1251).

# Drawbacks

This will be a breaking change, so all users serializers will be broken after a
major bump.
All pull requests will need to rebase since the architeture will change a lot.

# Alternatives

We can keep the way it is, and keep in mind to not add another namespace as a
public API.

# Unresolved questions

What is the better class name to be used to the class that will be inherited at
the creation of a serializer. This can be discussed in other RFC or directly via
pull request.
