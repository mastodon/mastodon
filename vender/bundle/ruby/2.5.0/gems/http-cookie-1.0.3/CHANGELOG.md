## 1.0.3 (2016-09-30)

- Treat comma as normal character in HTTP::Cookie.cookie_value_to_hash
  instead of key-value pair separator.  This should fix the problem
  described in CVE-2016-7401.

## 1.0.2 (2013-09-10)

  - Fix HTTP::Cookie.parse so that it does not raise ArgumentError
    when it finds a bad name or value that is parsable but considered
    invalid.

## 1.0.1 (2013-04-21)

  - Minor error handling improvements and documentation updates.

  - Argument error regarding specifying store/saver classes no longer
    raises IndexError, but either ArgumentError or TypeError.

## 1.0.0 (2013-04-17)

  - Initial Release.
