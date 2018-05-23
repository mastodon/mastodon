# HTTP::Cookie

HTTP::Cookie is a ruby library to handle HTTP cookies in a way both
compliant with RFCs and compatible with today's major browsers.

It was originally a part of the
[Mechanize](https://github.com/sparklemotion/mechanize) library,
separated as an independent library in the hope of serving as a common
component that is reusable from any HTTP related piece of software.

The following is an incomplete list of its features:

* Its behavior is highly compatible with that of today's major web
  browsers.

* It is based on and conforms to RFC 6265 (the latest standard for the
  HTTP cookie mechanism) to a high extent, with real world conventions
  deeply in mind.

* It takes eTLD (effective TLD, also known as "Public Suffix") into
  account just as major browsers do, to reject cookies with an eTLD
  domain like "org", "co.jp", or "appspot.com".  This feature is
  brought to you by the domain_name gem.

* The number of cookies and the size are properly capped so that a
  cookie store does not get flooded.

* It supports the legacy Netscape cookies.txt format for
  serialization, maximizing the interoperability with other
  implementations.

* It supports the cookies.sqlite format adopted by Mozilla Firefox for
  backend store database which can be shared among multiple program
  instances.

* It is relatively easy to add a new serialization format or a backend
  store because of its modular API.

## Installation

Add this line to your application's `Gemfile`:

    gem 'http-cookie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http-cookie

## Usage

    ########################
    # Client side example 1
    ########################

    # Initialize a cookie jar
    jar = HTTP::CookieJar.new

    # Load from a file
    jar.load(filename) if File.exist?(filename)

    # Store received cookies, where uri is the origin of this header
    header["Set-Cookie"].each { |value|
      jar.parse(value, uri)
    }

    # ...

    # Set the Cookie header value, where uri is the destination URI
    header["Cookie"] = HTTP::Cookie.cookie_value(jar.cookies(uri))

    # Save to a file
    jar.save(filename)


    ########################
    # Client side example 2
    ########################

    # Initialize a cookie jar using a Mozilla compatible SQLite3 backend
    jar = HTTP::CookieJar.new(store: :mozilla, filename: 'cookies.sqlite')

    # There is no need for load & save in this backend.

    # Store received cookies, where uri is the origin of this header
    header["Set-Cookie"].each { |value|
      jar.parse(value, uri)
    }

    # ...

    # Set the Cookie header value, where uri is the destination URI
    header["Cookie"] = HTTP::Cookie.cookie_value(jar.cookies(uri))


    ########################
    # Server side example
    ########################

    # Generate a domain cookie
    cookie1 = HTTP::Cookie.new("uid", "u12345", domain: 'example.org',
                                                for_domain: true,
                                                path: '/',
                                                max_age: 7*86400)

    # Add it to the Set-Cookie response header
    header['Set-Cookie'] = cookie1.set_cookie_value

    # Generate a host-only cookie
    cookie2 = HTTP::Cookie.new("aid", "a12345", origin: my_url,
                                                path: '/',
                                                max_age: 7*86400)

    # Add it to the Set-Cookie response header
    header['Set-Cookie'] = cookie2.set_cookie_value


## Incompatibilities with Mechanize::Cookie/CookieJar

There are several incompatibilities between
Mechanize::Cookie/CookieJar and HTTP::Cookie/CookieJar.  Below
is how to rewrite existing code written for Mechanize::Cookie with
equivalent using HTTP::Cookie:

- Mechanize::Cookie.parse

    The parameter order changed in HTTP::Cookie.parse.

        # before
        cookies1 = Mechanize::Cookie.parse(uri, set_cookie1)
        cookies2 = Mechanize::Cookie.parse(uri, set_cookie2, log)

        # after
        cookies1 = HTTP::Cookie.parse(set_cookie1, uri_or_url)
        cookies2 = HTTP::Cookie.parse(set_cookie2, uri_or_url, logger: log)
        # or you can directly store parsed cookies in your jar
        jar.parse(set_cookie1, uri_or_url)
        jar.parse(set_cookie1, uri_or_url, logger: log)

- Mechanize::Cookie#version, #version=

    There is no longer a sense of version in the HTTP cookie
    specification.  The only version number ever defined was zero, and
    there will be no other version defined since the version attribute
    has been removed in RFC 6265.

- Mechanize::Cookie#comment, #comment=

    Ditto.  The comment attribute has been removed in RFC 6265.

- Mechanize::Cookie#set_domain

    This method was unintentionally made public.  Simply use
    HTTP::Cookie#domain=.

        # before
        cookie.set_domain(domain)

        # after
        cookie.domain = domain

- Mechanize::CookieJar#add, #add!

    Always use HTTP::CookieJar#add.

        # before
        jar.add!(cookie1)
        jar.add(uri, cookie2)

        # after
        jar.add(cookie1)
        cookie2.origin = uri; jar.add(cookie2)  # or specify origin in parse() or new()

- Mechanize::CookieJar#clear!

    Use HTTP::Cookiejar#clear.

        # before
        jar.clear!

        # after
        jar.clear

- Mechanize::CookieJar#save_as

    Use HTTP::CookieJar#save.

        # before
        jar.save_as(file)

        # after
        jar.save(file)

- Mechanize::CookieJar#jar

    There is no direct access to the internal hash in HTTP::CookieJar
    since it has introduced an abstract store layer.  If you want to
    tweak the internals of the hash store, try creating a new store
    class referring to the default store class
    HTTP::CookieJar::HashStore.

    If you desperately need it you can access it by
    `jar.store.instance_variable_get(:@jar)`, but there is no
    guarantee that it will remain available in the future.


HTTP::Cookie/CookieJar raise runtime errors to help migration, so
after replacing the class names, try running your test code once to
find out how to fix your code base.

### File formats

The YAML serialization format has changed, and HTTP::CookieJar#load
cannot import what is written in a YAML file saved by
Mechanize::CookieJar#save_as.  HTTP::CookieJar#load will not raise an
exception if an incompatible YAML file is given, but the content is
silently ignored.

Note that there is (obviously) no forward compatibillity with this.
Trying to load a YAML file saved by HTTP::CookieJar with
Mechanize::CookieJar will fail in runtime error.

On the other hand, there has been (and will ever be) no change in the
cookies.txt format, so use it instead if compatibility is significant.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
