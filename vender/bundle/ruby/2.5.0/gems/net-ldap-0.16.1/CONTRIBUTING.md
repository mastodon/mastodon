# Contribution guide

Thank you for using net-ldap. If you'd like to help, keep these guidelines in
mind.

## Submitting a New Issue

If you find a bug, or would like to propose an idea, file a [new issue][issues].
Include as many details as possible:

- Version of net-ldap gem
- LDAP server version
- Queries, connection information, any other input
- output or error messages

## Sending a Pull Request

[Pull requests][pr] are always welcome!

Check out [the project's issues list][issues] for ideas on what could be improved.

Before sending, please add tests and ensure the test suite passes.

To run the full suite:

  `bundle exec rake`

To run a specific test file:

  `bundle exec ruby test/test_ldap.rb`

To run a specific test:

  `bundle exec ruby test/test_ldap.rb -n test_instrument_bind`

Pull requests will trigger automatic continuous integration builds on
[TravisCI][travis]. To run integration tests locally, see the `test/support`
folder.

## Styleguide

```ruby
# 1.9+ style hashes
{key: "value"}

# Multi-line arguments with `\`
MyClass.new \
  foo: 'bar',
  baz: 'garply'
```

[issues]: https://github.com/ruby-net-ldap/ruby-net-ldap/issues
[pr]: https://help.github.com/articles/using-pull-requests
[travis]: https://travis-ci.org/ruby-ldap/ruby-net-ldap
