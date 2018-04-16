# JWT

[![Gem Version](https://badge.fury.io/rb/jwt.svg)](https://badge.fury.io/rb/jwt)
[![Build Status](https://travis-ci.org/jwt/ruby-jwt.svg)](https://travis-ci.org/jwt/ruby-jwt)
[![Code Climate](https://codeclimate.com/github/jwt/ruby-jwt/badges/gpa.svg)](https://codeclimate.com/github/jwt/ruby-jwt)
[![Test Coverage](https://codeclimate.com/github/jwt/ruby-jwt/badges/coverage.svg)](https://codeclimate.com/github/jwt/ruby-jwt/coverage)
[![Issue Count](https://codeclimate.com/github/jwt/ruby-jwt/badges/issue_count.svg)](https://codeclimate.com/github/jwt/ruby-jwt)

A pure ruby implementation of the [RFC 7519 OAuth JSON Web Token (JWT)](https://tools.ietf.org/html/rfc7519) standard.

If you have further questions related to development or usage, join us: [ruby-jwt google group](https://groups.google.com/forum/#!forum/ruby-jwt).

## Announcements

* Ruby 1.9.3 support was dropped at December 31st, 2016.
* Version 1.5.3 yanked. See: [#132](https://github.com/jwt/ruby-jwt/issues/132) and [#133](https://github.com/jwt/ruby-jwt/issues/133)

## Installing

### Using Rubygems:
```bash
sudo gem install jwt
```

### Using Bundler:
Add the following to your Gemfile
```
gem 'jwt'
```
And run `bundle install`

## Algorithms and Usage

The JWT spec supports NONE, HMAC, RSASSA, ECDSA and RSASSA-PSS algorithms for cryptographic signing. Currently the jwt gem supports NONE, HMAC, RSASSA and ECDSA. If you are using cryptographic signing, you need to specify the algorithm in the options hash whenever you call JWT.decode to ensure that an attacker [cannot bypass the algorithm verification step](https://auth0.com/blog/2015/03/31/critical-vulnerabilities-in-json-web-token-libraries/).

See: [ JSON Web Algorithms (JWA) 3.1. "alg" (Algorithm) Header Parameter Values for JWS](https://tools.ietf.org/html/rfc7518#section-3.1)

**NONE**

* none - unsigned token

```ruby
require 'jwt'

payload = {:data => 'test'}

# IMPORTANT: set nil as password parameter
token = JWT.encode payload, nil, 'none'

# eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJkYXRhIjoidGVzdCJ9.
puts token

# Set password to nil and validation to false otherwise this won't work
decoded_token = JWT.decode token, nil, false

# Array
# [
#   {"data"=>"test"}, # payload
#   {"alg"=>"none"} # header
# ]
puts decoded_token
```

**HMAC**

* HS256 - HMAC using SHA-256 hash algorithm
* HS512256 - HMAC using SHA-512-256 hash algorithm (only available with RbNaCl; see note below)
* HS384 - HMAC using SHA-384 hash algorithm
* HS512 - HMAC using SHA-512 hash algorithm

```ruby
hmac_secret = 'my$ecretK3y'

token = JWT.encode payload, hmac_secret, 'HS256'

# eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJkYXRhIjoidGVzdCJ9.ZxW8go9hz3ETCSfxFxpwSkYg_602gOPKearsf6DsxgY
puts token

decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }

# Array
# [
#   {"data"=>"test"}, # payload
#   {"alg"=>"HS256"} # header
# ]
puts decoded_token
```

Note: If [RbNaCl](https://github.com/cryptosphere/rbnacl) is loadable, ruby-jwt will use it for HMAC-SHA256, HMAC-SHA512-256, and HMAC-SHA512. RbNaCl enforces a maximum key size of 32 bytes for these algorithms.

[RbNaCl](https://github.com/cryptosphere/rbnacl) requires
[libsodium](https://github.com/jedisct1/libsodium), it can be installed
on MacOS with `brew install libsodium`.

**RSA**

* RS256 - RSA using SHA-256 hash algorithm
* RS384 - RSA using SHA-384 hash algorithm
* RS512 - RSA using SHA-512 hash algorithm

```ruby
rsa_private = OpenSSL::PKey::RSA.generate 2048
rsa_public = rsa_private.public_key

token = JWT.encode payload, rsa_private, 'RS256'

# eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJ0ZXN0IjoiZGF0YSJ9.c2FynXNyi6_PeKxrDGxfS3OLwQ8lTDbWBWdq7oMviCy2ZfFpzvW2E_odCWJrbLof-eplHCsKzW7MGAntHMALXgclm_Cs9i2Exi6BZHzpr9suYkrhIjwqV1tCgMBCQpdeMwIq6SyKVjgH3L51ivIt0-GDDPDH1Rcut3jRQzp3Q35bg3tcI2iVg7t3Msvl9QrxXAdYNFiS5KXH22aJZ8X_O2HgqVYBXfSB1ygTYUmKTIIyLbntPQ7R22rFko1knGWOgQCoYXwbtpuKRZVFrxX958L2gUWgb4jEQNf3fhOtkBm1mJpj-7BGst00o8g_3P2zHy-3aKgpPo1XlKQGjRrrxA
puts token

decoded_token = JWT.decode token, rsa_public, true, { :algorithm => 'RS256' }

# Array
# [
#   {"data"=>"test"}, # payload
#   {"alg"=>"RS256"} # header
# ]
puts decoded_token
```

**ECDSA**

* ES256 - ECDSA using P-256 and SHA-256
* ES384 - ECDSA using P-384 and SHA-384
* ES512 - ECDSA using P-521 and SHA-512

```ruby
ecdsa_key = OpenSSL::PKey::EC.new 'prime256v1'
ecdsa_key.generate_key
ecdsa_public = OpenSSL::PKey::EC.new ecdsa_key
ecdsa_public.private_key = nil

token = JWT.encode payload, ecdsa_key, 'ES256'

# eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJ0ZXN0IjoiZGF0YSJ9.MEQCIAtShrxRwP1L9SapqaT4f7hajDJH4t_rfm-YlZcNDsBNAiB64M4-JRfyS8nRMlywtQ9lHbvvec9U54KznzOe1YxTyA
puts token

decoded_token = JWT.decode token, ecdsa_public, true, { :algorithm => 'ES256' }

# Array
# [
#    {"test"=>"data"}, # payload
#    {"alg"=>"ES256"} # header
# ]
puts decoded_token
```

**EDDSA**

In order to use this algorithm you need to add the `RbNaCl` gem to you `Gemfile`.

```ruby
gem 'rbnacl'
```

For more detailed installation instruction check the official [repository](https://github.com/cryptosphere/rbnacl) on GitHub.

* ED25519 

```ruby 
private_key = RbNaCl::Signatures::Ed25519::SigningKey.new("abcdefghijklmnopqrstuvwxyzABCDEF")
public_key = private_key.verify_key
token = JWT.encode payload, private_key, 'ED25519' 

# eyJhbGciOiJFRDI1NTE5In0.eyJ0ZXN0IjoiZGF0YSJ9.-Ki0vxVOlsPXovPsYRT_9OXrLSgQd4RDAgCLY_PLmcP4q32RYy-yUUmX82ycegdekR9wo26me1wOzjmSU5nTCQ
puts token

decoded_token = JWT.decode token, public_key, true, {:algorithm => 'ED25519' } 
# Array
# [
#  {"test"=>"data"}, # payload
#  {"alg"=>"ED25519"} # header
# ]

```

**RSASSA-PSS**

Not implemented.

## Support for reserved claim names
JSON Web Token defines some reserved claim names and defines how they should be
used. JWT supports these reserved claim names:

 - 'exp' (Expiration Time) Claim
 - 'nbf' (Not Before Time) Claim
 - 'iss' (Issuer) Claim
 - 'aud' (Audience) Claim
 - 'jti' (JWT ID) Claim
 - 'iat' (Issued At) Claim
 - 'sub' (Subject) Claim

## Add custom header fields
Ruby-jwt gem supports custom [header fields] (https://tools.ietf.org/html/rfc7519#section-5)
To add custom header fields you need to pass `header_fields` parameter

```ruby
token = JWT.encode payload, key, algorithm='HS256', header_fields={}
```

**Example:**

```ruby
require 'jwt'

payload = {:data => 'test'}

# IMPORTANT: set nil as password parameter
token = JWT.encode payload, nil, 'none', { :typ => "JWT" }

# eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJkYXRhIjoidGVzdCJ9.
puts token

# Set password to nil and validation to false otherwise this won't work
decoded_token = JWT.decode token, nil, false

# Array
# [
#   {"data"=>"test"}, # payload
#   {"typ"=>"JWT", "alg"=>"none"} # header
# ]
puts decoded_token
```

### Expiration Time Claim

From [Oauth JSON Web Token 4.1.4. "exp" (Expiration Time) Claim](https://tools.ietf.org/html/rfc7519#section-4.1.4):

> The `exp` (expiration time) claim identifies the expiration time on or after which the JWT MUST NOT be accepted for processing. The processing of the `exp` claim requires that the current date/time MUST be before the expiration date/time listed in the `exp` claim. Implementers MAY provide for some small `leeway`, usually no more than a few minutes, to account for clock skew. Its value MUST be a number containing a ***NumericDate*** value. Use of this claim is OPTIONAL.

**Handle Expiration Claim**

```ruby
exp = Time.now.to_i + 4 * 3600
exp_payload = { :data => 'data', :exp => exp }

token = JWT.encode exp_payload, hmac_secret, 'HS256'

begin
  decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }
rescue JWT::ExpiredSignature
  # Handle expired token, e.g. logout user or deny access
end
```

**Adding Leeway**

```ruby
exp = Time.now.to_i - 10
leeway = 30 # seconds

exp_payload = { :data => 'data', :exp => exp }

# build expired token
token = JWT.encode exp_payload, hmac_secret, 'HS256'

begin
  # add leeway to ensure the token is still accepted
  decoded_token = JWT.decode token, hmac_secret, true, { :exp_leeway => leeway, :algorithm => 'HS256' }
rescue JWT::ExpiredSignature
  # Handle expired token, e.g. logout user or deny access
end
```

### Not Before Time Claim

From [Oauth JSON Web Token 4.1.5. "nbf" (Not Before) Claim](https://tools.ietf.org/html/rfc7519#section-4.1.5):

> The `nbf` (not before) claim identifies the time before which the JWT MUST NOT be accepted for processing. The processing of the `nbf` claim requires that the current date/time MUST be after or equal to the not-before date/time listed in the `nbf` claim. Implementers MAY provide for some small `leeway`, usually no more than a few minutes, to account for clock skew. Its value MUST be a number containing a ***NumericDate*** value. Use of this claim is OPTIONAL.

**Handle Not Before Claim**

```ruby
nbf = Time.now.to_i - 3600
nbf_payload = { :data => 'data', :nbf => nbf }

token = JWT.encode nbf_payload, hmac_secret, 'HS256'

begin
  decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }
rescue JWT::ImmatureSignature
  # Handle invalid token, e.g. logout user or deny access
end
```

**Adding Leeway**

```ruby
nbf = Time.now.to_i + 10
leeway = 30

nbf_payload = { :data => 'data', :nbf => nbf }

# build expired token
token = JWT.encode nbf_payload, hmac_secret, 'HS256'

begin
  # add leeway to ensure the token is valid
  decoded_token = JWT.decode token, hmac_secret, true, { :nbf_leeway => leeway, :algorithm => 'HS256' }
rescue JWT::ImmatureSignature
  # Handle invalid token, e.g. logout user or deny access
end
```

### Issuer Claim

From [Oauth JSON Web Token 4.1.1. "iss" (Issuer) Claim](https://tools.ietf.org/html/rfc7519#section-4.1.1):

> The `iss` (issuer) claim identifies the principal that issued the JWT. The processing of this claim is generally application specific. The `iss` value is a case-sensitive string containing a ***StringOrURI*** value. Use of this claim is OPTIONAL.

You can pass multiple allowed issuers as an Array, verification will pass if one of them matches the `iss` value in the payload.

```ruby
iss = 'My Awesome Company Inc. or https://my.awesome.website/'
iss_payload = { :data => 'data', :iss => iss }

token = JWT.encode iss_payload, hmac_secret, 'HS256'

begin
  # Add iss to the validation to check if the token has been manipulated
  decoded_token = JWT.decode token, hmac_secret, true, { :iss => iss, :verify_iss => true, :algorithm => 'HS256' }
rescue JWT::InvalidIssuerError
  # Handle invalid token, e.g. logout user or deny access
end
```

### Audience Claim

From [Oauth JSON Web Token 4.1.3. "aud" (Audience) Claim](https://tools.ietf.org/html/rfc7519#section-4.1.3):

> The `aud` (audience) claim identifies the recipients that the JWT is intended for. Each principal intended to process the JWT MUST identify itself with a value in the audience claim. If the principal processing the claim does not identify itself with a value in the `aud` claim when this claim is present, then the JWT MUST be rejected. In the general case, the `aud` value is an array of case-sensitive strings, each containing a ***StringOrURI*** value. In the special case when the JWT has one audience, the `aud` value MAY be a single case-sensitive string containing a ***StringOrURI*** value. The interpretation of audience values is generally application specific. Use of this claim is OPTIONAL.

```ruby
aud = ['Young', 'Old']
aud_payload = { :data => 'data', :aud => aud }

token = JWT.encode aud_payload, hmac_secret, 'HS256'

begin
  # Add aud to the validation to check if the token has been manipulated
  decoded_token = JWT.decode token, hmac_secret, true, { :aud => aud, :verify_aud => true, :algorithm => 'HS256' }
rescue JWT::InvalidAudError
  # Handle invalid token, e.g. logout user or deny access
  puts 'Audience Error'
end
```

### JWT ID Claim

From [Oauth JSON Web Token 4.1.7. "jti" (JWT ID) Claim](https://tools.ietf.org/html/rfc7519#section-4.1.7):

> The `jti` (JWT ID) claim provides a unique identifier for the JWT. The identifier value MUST be assigned in a manner that ensures that there is a negligible probability that the same value will be accidentally assigned to a different data object; if the application uses multiple issuers, collisions MUST be prevented among values produced by different issuers as well. The `jti` claim can be used to prevent the JWT from being replayed. The `jti` value is a case-sensitive string. Use of this claim is OPTIONAL.

```ruby
# Use the secret and iat to create a unique key per request to prevent replay attacks
jti_raw = [hmac_secret, iat].join(':').to_s
jti = Digest::MD5.hexdigest(jti_raw)
jti_payload = { :data => 'data', :iat => iat, :jti => jti }

token = JWT.encode jti_payload, hmac_secret, 'HS256'

begin
  # If :verify_jti is true, validation will pass if a JTI is present
  #decoded_token = JWT.decode token, hmac_secret, true, { :verify_jti => true, :algorithm => 'HS256' }
  # Alternatively, pass a proc with your own code to check if the JTI has already been used
  decoded_token = JWT.decode token, hmac_secret, true, { :verify_jti => proc { |jti| my_validation_method(jti) }, :algorithm => 'HS256' }
rescue JWT::InvalidJtiError
  # Handle invalid token, e.g. logout user or deny access
  puts 'Error'
end

```

### Issued At Claim

From [Oauth JSON Web Token 4.1.6. "iat" (Issued At) Claim](https://tools.ietf.org/html/rfc7519#section-4.1.6):

> The `iat` (issued at) claim identifies the time at which the JWT was issued. This claim can be used to determine the age of the JWT. Its value MUST be a number containing a ***NumericDate*** value. Use of this claim is OPTIONAL.

**Handle Issued At Claim**

```ruby
iat = Time.now.to_i
iat_payload = { :data => 'data', :iat => iat }

token = JWT.encode iat_payload, hmac_secret, 'HS256'

begin
  # Add iat to the validation to check if the token has been manipulated
  decoded_token = JWT.decode token, hmac_secret, true, { :verify_iat => true, :algorithm => 'HS256' }
rescue JWT::InvalidIatError
  # Handle invalid token, e.g. logout user or deny access
end
```

**Adding Leeway**

```ruby
iat = Time.now.to_i + 10
leeway = 30 # seconds

iat_payload = { :data => 'data', :iat => iat }

# build token issued in the future
token = JWT.encode iat_payload, hmac_secret, 'HS256'

begin
  # add leeway to ensure the token is accepted
  decoded_token = JWT.decode token, hmac_secret, true, { :iat_leeway => leeway, :verify_iat => true, :algorithm => 'HS256' }
rescue JWT::InvalidIatError
  # Handle invalid token, e.g. logout user or deny access
end
```

### Subject Claim

From [Oauth JSON Web Token 4.1.2. "sub" (Subject) Claim](https://tools.ietf.org/html/rfc7519#section-4.1.2):

> The `sub` (subject) claim identifies the principal that is the subject of the JWT. The Claims in a JWT are normally statements about the subject. The subject value MUST either be scoped to be locally unique in the context of the issuer or be globally unique. The processing of this claim is generally application specific. The sub value is a case-sensitive string containing a ***StringOrURI*** value. Use of this claim is OPTIONAL.

```ruby
sub = 'Subject'
sub_payload = { :data => 'data', :sub => sub }

token = JWT.encode sub_payload, hmac_secret, 'HS256'

begin
  # Add sub to the validation to check if the token has been manipulated
  decoded_token = JWT.decode token, hmac_secret, true, { 'sub' => sub, :verify_sub => true, :algorithm => 'HS256' }
rescue JWT::InvalidSubError
  # Handle invalid token, e.g. logout user or deny access
end
```

# Development and Tests

We depend on [Bundler](http://rubygems.org/gems/bundler) for defining gemspec and performing releases to rubygems.org, which can be done with

```bash
rake release
```

The tests are written with rspec. Given you have installed the dependencies via bundler, you can run tests with

```bash
bundle exec rspec
```

**If you want a release cut with your PR, please include a version bump according to [Semantic Versioning](http://semver.org/)**

## Contributors

 * Jordan Brough <github.jordanb@xoxy.net>
 * Ilya Zhitomirskiy <ilya@joindiaspora.com>
 * Daniel Grippi <daniel@joindiaspora.com>
 * Jeff Lindsay <progrium@gmail.com>
 * Bob Aman <bob@sporkmonger.com>
 * Micah Gates <github@mgates.com>
 * Rob Wygand <rob@wygand.com>
 * Ariel Salomon (Oscil8)
 * Paul Battley <pbattley@gmail.com>
 * Zane Shannon [@zshannon](https://github.com/zshannon)
 * Brian Fletcher [@punkle](https://github.com/punkle)
 * Alex [@ZhangHanDong](https://github.com/ZhangHanDong)
 * John Downey [@jtdowney](https://github.com/jtdowney)
 * Adam Greene [@skippy](https://github.com/skippy)
 * Tim Rudat [@excpt](https://github.com/excpt) <timrudat@gmail.com> - Maintainer

## License

MIT

Copyright (c) 2011 Jeff Lindsay

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
