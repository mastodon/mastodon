# Rack::Test
[![Gem Version](https://badge.fury.io/rb/rack-test.svg)](https://badge.fury.io/rb/rack-test)
[<img src="https://travis-ci.org/rack-test/rack-test.svg?branch=master" />](https://travis-ci.org/rack-test/rack-test)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/codeclimate)
[![Test Coverage](https://codeclimate.com/github/codeclimate/codeclimate/badges/coverage.svg)](https://codeclimate.com/github/codeclimate/codeclimate/coverage)

Code: https://github.com/rack-test/rack-test

## Description

Rack::Test is a small, simple testing API for Rack apps. It can be used on its
own or as a reusable starting point for Web frameworks and testing libraries
to build on.

## Features

* Maintains a cookie jar across requests
* Easily follow redirects when desired
* Set request headers to be used by all subsequent requests
* Small footprint. Approximately 200 LOC

## Supported platforms

* 2.2.2+
* 2.3
* 2.4
* JRuby 9.1.+

If you are using Ruby 1.8, 1.9 or JRuby 1.7, use rack-test 0.6.3.

## Known incompatibilites

* `rack-test >= 0.71` _does not_ work with older Capybara versions (`< 2.17`). See [#214](https://github.com/rack-test/rack-test/issues/214) for more details.

## Examples
(The examples use `Test::Unit` but it's equally possible to use `rack-test` with other testing frameworks like `rspec`.)

```ruby
require "test/unit"
require "rack/test"

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['All responses are OK']] }
    builder = Rack::Builder.new
    builder.run app
  end

  def test_response_is_ok
    get '/'

    assert last_response.ok?
    assert_equal last_response.body, 'All responses are OK'
  end

  def set_request_headers
    header 'Accept-Charset', 'utf-8'
    get '/'

    assert last_response.ok?
    assert_equal last_response.body, 'All responses are OK'
  end

  def test_response_is_ok_for_other_paths
    get '/other_paths'

    assert last_response.ok?
    assert_equal last_response.body, 'All responses are OK'
  end

  def post_with_json
    # No assertion in this, we just demonstrate how you can post a JSON-encoded string.
    # By default, Rack::Test will use HTTP form encoding if you pass in a Hash as the
    # parameters, so make sure that `json` below is already a JSON-serialized string.
    post(uri, json, { 'CONTENT_TYPE' => 'application/json' })
  end
  
  def delete_with_url_params_and_body
    delete '/?foo=bar', JSON.generate('baz' => 'zot')
  end
end
```

If you want to test one app in isolation, you just return that app as shown above. But if you want to test the entire app stack, including middlewares, cascades etc. you need to parse the app defined in config.ru.

```ruby
OUTER_APP = Rack::Builder.parse_file("config.ru").first

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def test_root
    get "/"
    assert last_response.ok?
  end
end
```


## Install

To install the latest release as a gem:

```
gem install rack-test
```

Or via Bundler:

```
gem 'rack-test'
```

Or to install unreleased version via Bundler:

```
gem 'rack-test', github: 'rack-test', branch: 'master'
```

## Authors

- Contributions from Bryan Helmkamp, Simon Rozet, Pat Nakajima and others
- Much of the original code was extracted from Merb 1.0's request helper

## License
`rack-test` is released under the [MIT License](MIT-LICENSE.txt).

## Contribution

Contributions are welcome. Please make sure to:

* Use a regular forking workflow
* Write tests for the new or changed behaviour
* Provide an explanation/motivation in your commit message / PR message
* Ensure History.txt is updated

## Releasing

* Ensure `History.md` is up-to-date
* Bump VERSION in lib/rack/test/version.rb
* bundle exec thor :release
* Updated the [GitHub releases page](https://github.com/rack-test/rack-test/releases)
