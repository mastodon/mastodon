Goldfinger, a WebFinger client for Ruby
=======================================

[![Gem Version](http://img.shields.io/gem/v/goldfinger.svg)][gem]
[![Build Status](http://img.shields.io/travis/tootsuite/goldfinger.svg)][travis]
[![Dependency Status](http://img.shields.io/gemnasium/tootsuite/goldfinger.svg)][gemnasium]

[gem]: https://rubygems.org/gems/goldfinger
[travis]: https://travis-ci.org/tootsuite/goldfinger
[gemnasium]: https://gemnasium.com/tootsuite/goldfinger

A WebFinger client for Ruby. Supports `application/xrd+xml` and `application/jrd+json` responses. Raises `Goldfinger::NotFoundError` on failure to fetch the Webfinger or XRD data, can also raise `HTTP:Error` or `OpenSSL::SSL::SSLError` if something is wrong with the HTTPS connection it uses.

- **Does not** fall back to HTTP if HTTPS is not available
- **Does** check host-meta XRD, but *only* if the standard WebFinger path yielded no result

## Installation

    gem install goldfinger

## Usage

    data = Goldfinger.finger('acct:gargron@quitter.no')

    data.link('http://schemas.google.com/g/2010#updates-from').href
    # => "https://quitter.no/api/statuses/user_timeline/7477.atom"

    data.aliases
    # => ["https://quitter.no/user/7477", "https://quitter.no/gargron"]

    data.subject
    # => "acct:gargron@quitter.no"

## RFC support

The official WebFinger RFC is [7033](https://tools.ietf.org/html/rfc7033).
