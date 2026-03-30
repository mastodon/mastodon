# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'signature verification concern' do
  before do
    stub_tests_controller

    # Signature checking is time-dependent, so travel to a fixed date
    travel_to '2023-12-20T10:00:00Z'
  end

  after { Rails.application.reload_routes! }

  # Include the private key so the tests can be easily adjusted and reviewed
  let(:actor_keypair) do
    OpenSSL::PKey.read(<<~PEM_TEXT)
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAqIAYvNFGbZ5g4iiK6feSdXD4bDStFM58A7tHycYXaYtzZQpI
      eHXAmaXuZzXIwtrP4N0gIk8JNwZvXj2UPS+S07t0V9wNK94he01LV5EMz/GN4eNn
      FmDL64HIEuKLvV8TvgjbUPRD6Y5X0UpKi2ZIFLSb96Q5w0Z/k7ntpVKV52y8kz5F
      jr/O/0JuHryZe0yItzJh8kzFfeMf0EXzfSnaKvT7P9jhgC6uTre+jXyvVZjiHDrn
      qvvucdI3I7DRfXo1OqARBrLjy+TdseUAjNYJ+OuPRI1URIWQI01DCHqcohVu9+Ar
      +BiCjFp3ua+XMuJvrvbD61d1Fvig/9nbBRR+8QIDAQABAoIBAAgySHnFWI6gItR3
      fkfiqIm80cHCN3Xk1C6iiVu+3oBOZbHpW9R7vl9e/WOA/9O+LPjiSsQOegtWnVvd
      RRjrl7Hj20VDlZKv5Mssm6zOGAxksrcVbqwdj+fUJaNJCL0AyyseH0x/IE9T8rDC
      I1GH+3tB3JkhkIN/qjipdX5ab8MswEPu8IC4ViTpdBgWYY/xBcAHPw4xuL0tcwzh
      FBlf4DqoEVQo8GdK5GAJ2Ny0S4xbXHUURzx/R4y4CCts7niAiLGqd9jmLU1kUTMk
      QcXfQYK6l+unLc7wDYAz7sFEHh04M48VjWwiIZJnlCqmQbLda7uhhu8zkF1DqZTu
      ulWDGQECgYEA0TIAc8BQBVab979DHEEmMdgqBwxLY3OIAk0b+r50h7VBGWCDPRsC
      STD73fQY3lNet/7/jgSGwwAlAJ5PpMXxXiZAE3bUwPmHzgF7pvIOOLhA8O07tHSO
      L2mvQe6NPzjZ+6iAO2U9PkClxcvGvPx2OBvisfHqZLmxC9PIVxzruQECgYEAzjM6
      BTUXa6T/qHvLFbN699BXsUOGmHBGaLRapFDBfVvgZrwqYQcZpBBhesLdGTGSqwE7
      gWsITPIJ+Ldo+38oGYyVys+w/V67q6ud7hgSDTW3hSvm+GboCjk6gzxlt9hQ0t9X
      8vfDOYhEXvVUJNv3mYO60ENqQhILO4bQ0zi+VfECgYBb/nUccfG+pzunU0Cb6Dp3
      qOuydcGhVmj1OhuXxLFSDG84Tazo7juvHA9mp7VX76mzmDuhpHPuxN2AzB2SBEoE
      cSW0aYld413JRfWukLuYTc6hJHIhBTCRwRQFFnae2s1hUdQySm8INT2xIc+fxBXo
      zrp+Ljg5Wz90SAnN5TX0AQKBgDaatDOq0o/r+tPYLHiLtfWoE4Dau+rkWJDjqdk3
      lXWn/e3WyHY3Vh/vQpEqxzgju45TXjmwaVtPATr+/usSykCxzP0PMPR3wMT+Rm1F
      rIoY/odij+CaB7qlWwxj0x/zRbwB7x1lZSp4HnrzBpxYL+JUUwVRxPLIKndSBTza
      GvVRAoGBAIVBcNcRQYF4fvZjDKAb4fdBsEuHmycqtRCsnkGOz6ebbEQznSaZ0tZE
      +JuouZaGjyp8uPjNGD5D7mIGbyoZ3KyG4mTXNxDAGBso1hrNDKGBOrGaPhZx8LgO
      4VXJ+ybXrATf4jr8ccZYsZdFpOphPzz+j55Mqg5vac5P1XjmsGTb
      -----END RSA PRIVATE KEY-----
    PEM_TEXT
  end

  context 'without a Signature header' do
    it 'does not treat the request as signed' do
      get '/activitypub/success'

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match(
        signed_request: false,
        signature_actor_id: nil,
        error: 'Request not signed'
      )
    end

    context 'when a signature is required' do
      it 'returns http unauthorized with appropriate error' do
        get '/activitypub/signature_required'

        expect(response).to have_http_status(401)
        expect(response.parsed_body).to match(
          error: 'Request not signed'
        )
      end
    end
  end

  context 'with an HTTP Signature (draft version)' do
    context 'with a known account' do
      let!(:actor) { Fabricate(:account, domain: 'remote.domain', uri: 'https://remote.domain/users/bob', private_key: nil, public_key: actor_keypair.public_key.to_pem) }

      context 'with a valid signature on a GET request' do
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="Z8ilar3J7bOwqZkMp7sL8sRs4B1FT+UorbmvWoE+A5UeoOJ3KBcUmbsh+k3wQwbP5gMNUrra9rEWabpasZGphLsbDxfbsWL3Cf0PllAc7c1c7AFEwnewtExI83/qqgEkfWc2z7UDutXc2NfgAx89Ox8DXU/fA2GG0jILjB6UpFyNugkY9rg6oI31UnvfVi3R7sr3/x8Ea3I9thPvqI2byF6cojknSpDAwYzeKdngX3TAQEGzFHz3SDWwyp3jeMWfwvVVbM38FxhvAnSumw7YwWW4L7M7h4M68isLimoT3yfCn2ucBVL5Dz8koBpYf/40w7QidClAwCafZQFC29yDOg=="' # rubocop:disable Layout/LineLength
        end

        it 'successfuly verifies signature', :aggregate_failures do
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'get /activitypub/success', { 'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT', 'Host' => 'www.example.com' })

          get '/activitypub/success', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: actor.id.to_s
          )
        end
      end

      context 'with a valid signature on a GET request that has a query string' do
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="SDMa4r/DQYMXYxVgYO2yEqGWWUXugKjVuz0I8dniQAk+aunzBaF2aPu+4grBfawAshlx1Xytl8lhb0H2MllEz16/tKY7rUrb70MK0w8ohXgpb0qs3YvQgdj4X24L1x2MnkFfKHR/J+7TBlnivq0HZqXm8EIkPWLv+eQxu8fbowLwHIVvRd/3t6FzvcfsE0UZKkoMEX02542MhwSif6cu7Ec/clsY9qgKahb9JVGOGS1op9Lvg/9y1mc8KCgD83U5IxVygYeYXaVQ6gixA9NgZiTCwEWzHM5ELm7w5hpdLFYxYOHg/3G3fiqJzpzNQAcCD4S4JxfE7hMI0IzVlNLT6A=="' # rubocop:disable Layout/LineLength
        end

        it 'successfuly verifies signature', :aggregate_failures do
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'get /activitypub/success?foo=42', { 'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT', 'Host' => 'www.example.com' })

          get '/activitypub/success?foo=42', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: actor.id.to_s
          )
        end
      end

      context 'when the query string is missing from the signature verification (compatibility quirk)' do
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="Z8ilar3J7bOwqZkMp7sL8sRs4B1FT+UorbmvWoE+A5UeoOJ3KBcUmbsh+k3wQwbP5gMNUrra9rEWabpasZGphLsbDxfbsWL3Cf0PllAc7c1c7AFEwnewtExI83/qqgEkfWc2z7UDutXc2NfgAx89Ox8DXU/fA2GG0jILjB6UpFyNugkY9rg6oI31UnvfVi3R7sr3/x8Ea3I9thPvqI2byF6cojknSpDAwYzeKdngX3TAQEGzFHz3SDWwyp3jeMWfwvVVbM38FxhvAnSumw7YwWW4L7M7h4M68isLimoT3yfCn2ucBVL5Dz8koBpYf/40w7QidClAwCafZQFC29yDOg=="' # rubocop:disable Layout/LineLength
        end

        it 'successfuly verifies signature', :aggregate_failures do
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'get /activitypub/success', { 'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT', 'Host' => 'www.example.com' })

          get '/activitypub/success?foo=42', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: actor.id.to_s
          )
        end
      end

      context 'with mismatching query string' do
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="SDMa4r/DQYMXYxVgYO2yEqGWWUXugKjVuz0I8dniQAk+aunzBaF2aPu+4grBfawAshlx1Xytl8lhb0H2MllEz16/tKY7rUrb70MK0w8ohXgpb0qs3YvQgdj4X24L1x2MnkFfKHR/J+7TBlnivq0HZqXm8EIkPWLv+eQxu8fbowLwHIVvRd/3t6FzvcfsE0UZKkoMEX02542MhwSif6cu7Ec/clsY9qgKahb9JVGOGS1op9Lvg/9y1mc8KCgD83U5IxVygYeYXaVQ6gixA9NgZiTCwEWzHM5ELm7w5hpdLFYxYOHg/3G3fiqJzpzNQAcCD4S4JxfE7hMI0IzVlNLT6A=="' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'get /activitypub/success?foo=42', { 'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT', 'Host' => 'www.example.com' })

          get '/activitypub/success?foo=43', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: anything
          )
        end
      end

      context 'with a mismatching path' do
        it 'fails to verify signature', :aggregate_failures do
          get '/activitypub/alternative-path', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Signature' => 'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="Z8ilar3J7bOwqZkMp7sL8sRs4B1FT+UorbmvWoE+A5UeoOJ3KBcUmbsh+k3wQwbP5gMNUrra9rEWabpasZGphLsbDxfbsWL3Cf0PllAc7c1c7AFEwnewtExI83/qqgEkfWc2z7UDutXc2NfgAx89Ox8DXU/fA2GG0jILjB6UpFyNugkY9rg6oI31UnvfVi3R7sr3/x8Ea3I9thPvqI2byF6cojknSpDAwYzeKdngX3TAQEGzFHz3SDWwyp3jeMWfwvVVbM38FxhvAnSumw7YwWW4L7M7h4M68isLimoT3yfCn2ucBVL5Dz8koBpYf/40w7QidClAwCafZQFC29yDOg=="', # rubocop:disable Layout/LineLength
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: anything
          )
        end
      end

      context 'with a mismatching method' do
        it 'fails to verify signature', :aggregate_failures do
          post '/activitypub/success', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Signature' => 'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="Z8ilar3J7bOwqZkMp7sL8sRs4B1FT+UorbmvWoE+A5UeoOJ3KBcUmbsh+k3wQwbP5gMNUrra9rEWabpasZGphLsbDxfbsWL3Cf0PllAc7c1c7AFEwnewtExI83/qqgEkfWc2z7UDutXc2NfgAx89Ox8DXU/fA2GG0jILjB6UpFyNugkY9rg6oI31UnvfVi3R7sr3/x8Ea3I9thPvqI2byF6cojknSpDAwYzeKdngX3TAQEGzFHz3SDWwyp3jeMWfwvVVbM38FxhvAnSumw7YwWW4L7M7h4M68isLimoT3yfCn2ucBVL5Dz8koBpYf/40w7QidClAwCafZQFC29yDOg=="', # rubocop:disable Layout/LineLength
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: anything
          )
        end
      end

      context 'with an unparsable date' do
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="d4B7nfx8RJcfdJDu1J//5WzPzK/hgtPkdzZx49lu5QhnE7qdV3lgyVimmhCFrO16bwvzIp9iRMyRLkNFxLiEeVaa1gqeKbldGSnU0B0OMjx7rFBa65vLuzWQOATDitVGiBEYqoK4v0DMuFCz2DtFaA/DIUZ3sty8bZ/Ea3U1nByLOO6MacARA3zhMSI0GNxGqsSmZmG0hPLavB3jIXoE3IDoQabMnC39jrlcO/a8h1iaxBm2WD8TejrImJullgqlJIFpKhIHI3ipQkvTGPlm9dx0y+beM06qBvWaWQcmT09eRIUefVsOAzIhUtS/7FVb/URhZvircIJDa7vtiFcmZQ=="' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'get /activitypub/success', { 'Date' => 'wrong date', 'Host' => 'www.example.com' })

          get '/activitypub/success', headers: {
            'Host' => 'www.example.com',
            'Date' => 'wrong date',
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: 'Invalid Date header: not RFC 2616 compliant date: "wrong date"'
          )
        end
      end

      context 'with a request older than a day' do
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="G1NuJv4zgoZ3B/ZIjzDWZHK4RC+5pYee74q8/LJEMCWXhcnAomcb9YHaqk1QYfQvcBUIXw3UZ3Q9xO8F9y0i8G5mzJHfQ+OgHqCoJk8EmGwsUXJMh5s1S5YFCRt8TT12TmJZz0VMqLq85ubueSYBM7QtUE/FzFIVLvz4RysgXxaXQKzdnM6+gbUEEKdCURpXdQt2NXQhp4MAmZH3+0lQoR6VxdsK0hx0Ji2PNp1nuqFTlYqNWZazVdLBN+9rETLRmvGXknvg9jOxTTppBVWnkAIl26HtLS3wwFVvz4pJzi9OQDOvLziehVyLNbU61hky+oJ215e2HuKSe2hxHNl1MA=="' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'get /activitypub/success', { 'Date' => 'Wed, 18 Dec 2023 10:00:00 GMT', 'Host' => 'www.example.com' })

          get '/activitypub/success', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 18 Dec 2023 10:00:00 GMT',
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: 'Signed request date outside acceptable time window'
          )
        end
      end

      context 'with a valid signature on a POST request' do
        let(:digest_header) { 'SHA-256=ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=' }
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="host date digest (request-target)",signature="gmhMjgMROGElJU3fpehV2acD5kMHeELi8EFP2UPHOdQ54H0r55AxIpji+J3lPe+N2qSb/4H1KXIh6f0lRu8TGSsu12OQmg5hiO8VA9flcA/mh9Lpk+qwlQZIPRqKP9xUEfqD+Z7ti5wPzDKrWAUK/7FIqWgcT/mlqB1R1MGkpMFc/q4CIs2OSNiWgA4K+Kp21oQxzC2kUuYob04gAZ7cyE/FTia5t08uv6lVYFdRsn4XNPn1MsHgFBwBMRG79ng3SyhoG4PrqBEi5q2IdLq3zfre/M6He3wlCpyO2VJNdGVoTIzeZ0Zz8jUscPV3XtWUchpGclLGSaKaq/JyNZeiYQ=="' # rubocop:disable Layout/LineLength
        end

        it 'successfuly verifies signature', :aggregate_failures do
          expect(digest_header).to eq digest_value('Hello world')
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'post /activitypub/success', { 'Host' => 'www.example.com', 'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT', 'Digest' => digest_header })

          post '/activitypub/success', params: 'Hello world', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Digest' => digest_header,
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: actor.id.to_s
          )
        end
      end

      context 'when the Digest of a POST request is not signed' do
        let(:digest_header) { 'SHA-256=ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=' }
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="host date (request-target)",signature="CPD704CG8aCm8X8qIP8kkkiGp1qwFLk/wMVQHOGP0Txxan8c2DZtg/KK7eN8RG8tHx8br/yS2hJs51x4kXImYukGzNJd7ihE3T8lp+9RI1tCcdobTzr/VcVJHDFySdQkg266GCMijRQRZfNvqlJLiisr817PI+gNVBI5qV+vnVd1XhWCEZ+YSmMe8UqYARXAYNqMykTheojqGpTeTFGPUpTQA2Fmt2BipwIjcFDm2Hpihl2kB0MUS0x3zPmHDuadvzoBbN6m3usPDLgYrpALlh+wDs1dYMntcwdwawRKY1oE1XNtgOSum12wntDq3uYL4gya2iPdcw3c929b4koUzw=="' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          expect(digest_header).to eq digest_value('Hello world')
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'post /activitypub/success', { 'Host' => 'www.example.com', 'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT' })

          post '/activitypub/success', params: 'Hello world', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Digest' => digest_header,
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: 'Mastodon requires the Digest header to be signed when doing a POST request'
          )
        end
      end

      context 'with a tampered body on a POST request' do
        let(:digest_header) { 'SHA-256=ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=' }
        let(:signature_header) do
          'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="host date digest (request-target)",signature="gmhMjgMROGElJU3fpehV2acD5kMHeELi8EFP2UPHOdQ54H0r55AxIpji+J3lPe+N2qSb/4H1KXIh6f0lRu8TGSsu12OQmg5hiO8VA9flcA/mh9Lpk+qwlQZIPRqKP9xUEfqD+Z7ti5wPzDKrWAUK/7FIqWgcT/mlqB1R1MGkpMFc/q4CIs2OSNiWgA4K+Kp21oQxzC2kUuYob04gAZ7cyE/FTia5t08uv6lVYFdRsn4XNPn1MsHgFBwBMRG79ng3SyhoG4PrqBEi5q2IdLq3zfre/M6He3wlCpyO2VJNdGVoTIzeZ0Zz8jUscPV3XtWUchpGclLGSaKaq/JyNZeiYQ=="' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          expect(digest_header).to_not eq digest_value('Hello world!')
          expect(signature_header).to eq build_signature_string(actor_keypair, 'https://remote.domain/users/bob#main-key', 'post /activitypub/success', { 'Host' => 'www.example.com', 'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT', 'Digest' => digest_header })

          post '/activitypub/success', params: 'Hello world!', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Digest' => 'SHA-256=ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=',
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: 'Invalid Digest value. Computed SHA-256 digest: wFNeS+K3n/2TKRMFQ2v4iTFOSj+uwF7P/Lt98xrZ5Ro=; given: ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw='
          )
        end
      end

      context 'with a tampered path in a POST request' do
        it 'fails to verify signature', :aggregate_failures do
          post '/activitypub/alternative-path', params: 'Hello world', headers: {
            'Host' => 'www.example.com',
            'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
            'Digest' => 'SHA-256=ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=',
            'Signature' => 'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="host date digest (request-target)",signature="gmhMjgMROGElJU3fpehV2acD5kMHeELi8EFP2UPHOdQ54H0r55AxIpji+J3lPe+N2qSb/4H1KXIh6f0lRu8TGSsu12OQmg5hiO8VA9flcA/mh9Lpk+qwlQZIPRqKP9xUEfqD+Z7ti5wPzDKrWAUK/7FIqWgcT/mlqB1R1MGkpMFc/q4CIs2OSNiWgA4K+Kp21oQxzC2kUuYob04gAZ7cyE/FTia5t08uv6lVYFdRsn4XNPn1MsHgFBwBMRG79ng3SyhoG4PrqBEi5q2IdLq3zfre/M6He3wlCpyO2VJNdGVoTIzeZ0Zz8jUscPV3XtWUchpGclLGSaKaq/JyNZeiYQ=="', # rubocop:disable Layout/LineLength
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: anything
          )
        end
      end
    end

    context 'with an inaccessible key' do
      before do
        stub_request(:get, 'https://remote.domain/users/alice#main-key').to_return(status: 404)
      end

      it 'fails to verify signature', :aggregate_failures do
        get '/activitypub/success', headers: {
          'Host' => 'www.example.com',
          'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT',
          'Signature' => 'keyId="https://remote.domain/users/alice#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="Z8ilar3J7bOwqZkMp7sL8sRs4B1FT+UorbmvWoE+A5UeoOJ3KBcUmbsh+k3wQwbP5gMNUrra9rEWabpasZGphLsbDxfbsWL3Cf0PllAc7c1c7AFEwnewtExI83/qqgEkfWc2z7UDutXc2NfgAx89Ox8DXU/fA2GG0jILjB6UpFyNugkY9rg6oI31UnvfVi3R7sr3/x8Ea3I9thPvqI2byF6cojknSpDAwYzeKdngX3TAQEGzFHz3SDWwyp3jeMWfwvVVbM38FxhvAnSumw7YwWW4L7M7h4M68isLimoT3yfCn2ucBVL5Dz8koBpYf/40w7QidClAwCafZQFC29yDOg=="', # rubocop:disable Layout/LineLength
        }

        expect(response.parsed_body).to match(
          signed_request: true,
          signature_actor_id: nil,
          error: 'Unable to fetch key JSON at https://remote.domain/users/alice#main-key'
        )
      end
    end
  end

  context 'with an HTTP Message Signature (final RFC version)' do
    context 'with a known account' do
      let!(:actor) { Fabricate(:account, domain: 'remote.domain', uri: 'https://remote.domain/users/bob', private_key: nil, public_key: actor_keypair.public_key.to_pem) }

      context 'with a valid signature on a GET request' do
        let(:signature_input) do
          'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:WfM6q/qBqhUyqPUDt9metjadJGtLLpmMTBzk/t+R3byKe4/TGAXC6vBB/M6NsD5qv8GCmQGtisCMQxJQO0IGODGzi+Jv+eqDJ50agMVXNV6nUOzY44c4/XTPoI98qyx1oEMa4Hefy3vSYKq96iDVAc+RDLCMTeGP3wn9wizjD1SNmU0RZI1bTB+eCkywMP9mM5zXzUOYF+Qkuf+WdEpPR1XUGPlnqfdvPalcKVfaI/VThBjI91D/lmUGoa69x4EBEHM+aJmW6086e7/dVh+FndKkdGfXslZXFZKi2flTGQZgEWLn948SqAaJQROkJg8B14Sb1NONS1qZBhK3Mum8Pg==:' # rubocop:disable Layout/LineLength
        end

        it 'successfully verifies signature', :aggregate_failures do
          get '/activitypub/success', headers: {
            'Host' => 'www.example.com',
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: actor.id.to_s
          )
        end
      end

      context 'with a valid signature on a GET request that has a query string' do
        let(:signature_input) do
          'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:JbC0oqoruKkT5p3bTASZZbHQP+EwUmT6+vBjEBw/KSkLPn+tKjEj0HHIMLA2Rw3bshZyzmsVD8+2UkPcwZYnE3gzuX0r0/gC8v4dSBfwGe7EBwpekB2xU8yHW4jawxiof2LmErvEocqcnI2uiA4IlJ09uz2Os/ARmf60lj+0Qf1qqzFeM7KoXJ331BUGMJ4cQ7iS4aO9RG4P8EJ+upe7Ik1LB/q9CZmk/6MFaB2lIemV0pcg2MwctpzMw9GWN1wL10hGxx+BPT2WCXdlPQmetVSoJ89WVV8S/4lQaCA1IucYUVDvBEFgMM//VJBuw7kg8wSTeAg9oKzbR2otLqv8Lg==:' # rubocop:disable Layout/LineLength
        end

        it 'successfuly verifies signature', :aggregate_failures do
          get '/activitypub/success?foo=42', headers: {
            'Host' => 'www.example.com',
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: actor.id.to_s
          )
        end
      end

      context 'with mismatching query string' do
        let(:signature_input) do
          'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:JbC0oqoruKkT5p3bTASZZbHQP+EwUmT6+vBjEBw/KSkLPn+tKjEj0HHIMLA2Rw3bshZyzmsVD8+2UkPcwZYnE3gzuX0r0/gC8v4dSBfwGe7EBwpekB2xU8yHW4jawxiof2LmErvEocqcnI2uiA4IlJ09uz2Os/ARmf60lj+0Qf1qqzFeM7KoXJ331BUGMJ4cQ7iS4aO9RG4P8EJ+upe7Ik1LB/q9CZmk/6MFaB2lIemV0pcg2MwctpzMw9GWN1wL10hGxx+BPT2WCXdlPQmetVSoJ89WVV8S/4lQaCA1IucYUVDvBEFgMM//VJBuw7kg8wSTeAg9oKzbR2otLqv8Lg==:' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          get '/activitypub/success?foo=43', headers: {
            'Host' => 'www.example.com',
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: anything
          )
        end
      end

      context 'with a mismatching path' do
        let(:signature_input) do
          'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:WfM6q/qBqhUyqPUDt9metjadJGtLLpmMTBzk/t+R3byKe4/TGAXC6vBB/M6NsD5qv8GCmQGtisCMQxJQO0IGODGzi+Jv+eqDJ50agMVXNV6nUOzY44c4/XTPoI98qyx1oEMa4Hefy3vSYKq96iDVAc+RDLCMTeGP3wn9wizjD1SNmU0RZI1bTB+eCkywMP9mM5zXzUOYF+Qkuf+WdEpPR1XUGPlnqfdvPalcKVfaI/VThBjI91D/lmUGoa69x4EBEHM+aJmW6086e7/dVh+FndKkdGfXslZXFZKi2flTGQZgEWLn948SqAaJQROkJg8B14Sb1NONS1qZBhK3Mum8Pg==:' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          get '/activitypub/alternative-path', headers: {
            'Host' => 'www.example.com',
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: anything
          )
        end
      end

      context 'with a mismatching method' do
        let(:signature_input) do
          'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:WfM6q/qBqhUyqPUDt9metjadJGtLLpmMTBzk/t+R3byKe4/TGAXC6vBB/M6NsD5qv8GCmQGtisCMQxJQO0IGODGzi+Jv+eqDJ50agMVXNV6nUOzY44c4/XTPoI98qyx1oEMa4Hefy3vSYKq96iDVAc+RDLCMTeGP3wn9wizjD1SNmU0RZI1bTB+eCkywMP9mM5zXzUOYF+Qkuf+WdEpPR1XUGPlnqfdvPalcKVfaI/VThBjI91D/lmUGoa69x4EBEHM+aJmW6086e7/dVh+FndKkdGfXslZXFZKi2flTGQZgEWLn948SqAaJQROkJg8B14Sb1NONS1qZBhK3Mum8Pg==:' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          post '/activitypub/success', headers: {
            'Host' => 'www.example.com',
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: anything
          )
        end
      end

      context 'with a request older than a day' do
        let(:signature_input) do
          'sig1=("@method" "@target-uri");created=1702893600;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:LtvwxwAAyiP7fGzsgKDRUHaZNNclAq6ScmH7RY+KERgaJcrjHFuqaYraQ3d9JVNsDJzZhdtJs+7UDPfIUjYNwWj/5KRQscB2sMQ9+EYR2tBDen+K5TILv/SXoWUdvVU/3vbGMiVIACgynaXokySNrE8AGFWdrzT5NbxE+/pJ0tkB3uWO7LfFpm0ipzo0NN07CGC2AUVl6WxsiTGWtFRqVrrHFmYmRcVYn7NxkKytx8eDg95cyIsB4xAHz8i++NqZHiXaooh79OdhOy10kMWHFDbuy/AijjI3aGtGriAbXdxb8O3nwoSCvfEJ5f7qQ+iMJl/fLvFOUZElZgRo3mk2lA==:' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          get '/activitypub/success', headers: {
            'Host' => 'www.example.com',
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: 'Signed request date outside acceptable time window'
          )
        end
      end

      context 'with a valid signature on a POST request' do
        let(:digest_header) { 'sha-256=:ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=:' }
        let(:signature_input) do
          'sig1=("@method" "@target-uri" "content-digest");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:c4jGY/PnOV4CwyvNnAmY6NLX0sf6EtbKu7kYseNARRZaq128PrP0GNQ4cd3XsX9cbMfJMw1ntI4zuEC81ncW8g+90OHP02bX0LkT57RweUtN4CSA01hRqSVe/MW32tjGixCiItvWqjNHoIZnZApu1bd+M3zMR+VCEue4/8a0D2eRrvfQxJUUBXZR1ZTRFlf1LNFDW3U7cuTbAKYr2zWVr7on+h2vA+vzEND9WE8z1SHd6SIFFgP0QRqrCXYx+vsTs3aLusTsamRWissoycJGexb64mI9iqiD8SD+uN1xk6iRU3nkUmhUquugjlOFyjxbbLo5ZnYjsECMt/BW+Catxw==:' # rubocop:disable Layout/LineLength
        end

        it 'successfuly verifies signature', :aggregate_failures do
          post '/activitypub/success', params: 'Hello world', headers: {
            'Host' => 'www.example.com',
            'Content-Digest' => digest_header,
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: actor.id.to_s
          )
        end
      end

      context 'when the Digest of a POST request is not signed' do
        let(:digest_header) { 'sha-256=:ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=:' }
        let(:signature_input) do
          'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:Rhc5CzxdUYCzwo3V7y5wjEIN4o2XD90Bhf7lTDg2TIlp33ygl6ufwZpQ156fLJ0aUCkJ4+9KQsHBIkxF4PZJn8d/ZIfz3dpHJAVyMErAToSw+36V61mbnnnJxIPZPvmTT3zYCL7HPv+3GItOA4SqBhjJZRRJwOIW6NmmyrmSpc8xF9klnkeyGbYYRusaG7w6BDzM7ECCttxk120v1rHkGyqVON9fQADqs2LNqPa9WM9kWKiC5LhnZSYgoojhPmhniiA4NpgprncEBo4dOIC8CJihafWVSf+CZp3eogb/hn3Yd0//Pz0ta/lVtLGdb7t9f0rQFiqZfwIcCCz51nDMKw==:' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          post '/activitypub/success', params: 'Hello world', headers: {
            'Host' => 'www.example.com',
            'Content-Digest' => digest_header,
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: 'Mastodon requires the Content-Digest header to be signed when doing a POST request'
          )
        end
      end

      context 'with a tampered body on a POST request' do
        let(:digest_header) { 'sha-256=:ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=:' }
        let(:signature_input) do
          'sig1=("@method" "@target-uri" "content-digest");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:c4jGY/PnOV4CwyvNnAmY6NLX0sf6EtbKu7kYseNARRZaq128PrP0GNQ4cd3XsX9cbMfJMw1ntI4zuEC81ncW8g+90OHP02bX0LkT57RweUtN4CSA01hRqSVe/MW32tjGixCiItvWqjNHoIZnZApu1bd+M3zMR+VCEue4/8a0D2eRrvfQxJUUBXZR1ZTRFlf1LNFDW3U7cuTbAKYr2zWVr7on+h2vA+vzEND9WE8z1SHd6SIFFgP0QRqrCXYx+vsTs3aLusTsamRWissoycJGexb64mI9iqiD8SD+uN1xk6iRU3nkUmhUquugjlOFyjxbbLo5ZnYjsECMt/BW+Catxw==:' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          post '/activitypub/success', params: 'Hello world!', headers: {
            'Host' => 'www.example.com',
            'Content-Digest' => digest_header,
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: 'Invalid Digest value. Computed SHA-256 digest: wFNeS+K3n/2TKRMFQ2v4iTFOSj+uwF7P/Lt98xrZ5Ro=; given: ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw='
          )
        end
      end

      context 'with a tampered path in a POST request' do
        let(:digest_header) { 'sha-256=:ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=:' }
        let(:signature_input) do
          'sig1=("@method" "@target-uri" "content-digest");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:aJmJgCOuAJD1su2QeeD7Y9wfda8dqReyuau1EBWAz1DYwKWx5kVosONGgJb+XZFugh6CQ15XDFz0vRJRYdt6GyquloOFYLzPYWp3mYRlMhvehR64ALeGIwJbb460/tOeX2PwaFNVBrqLBAHf8PZDAPCxE8Q9cPWhewwQQirBZTm0xhOy8nRkSEfMish87JEQLkEzH+pZQDYIpv+oE+Tz6gow6bllCmjUd8vgLABpc7sZJTz5qklfOMqFczW6HvVxvQK/9G7V509u2z5I2PC/q+XdEs+jC0uzuer5baTJgL2q37gvnKzmz7pB+kbtBz5tmGNEMVLtPYQIEYjVI4Y34Q==:' # rubocop:disable Layout/LineLength
        end

        it 'fails to verify signature', :aggregate_failures do
          post '/activitypub/alternative-path', params: 'Hello world', headers: {
            'Host' => 'www.example.com',
            'Content-Digest' => digest_header,
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(200)
          expect(response.parsed_body).to match(
            signed_request: true,
            signature_actor_id: nil,
            error: anything
          )
        end
      end

      context 'with a malformed `Content-Digest` header' do
        let(:digest_header) { 'SHA-256=:ZOyIygCyaOW6GjVnihtTFtIS9PNmskdyMlNKiuyjfzw=:' }
        let(:signature_input) do
          'sig1=("@method" "@target-uri" "content-digest");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
        end
        let(:signature_header) do
          'sig1=:aXua24cIlBi8akNXg/Vc5pU8fNGXo0f4U2qQk42iWoIaCcH3G+z2edPMQTNM/aZmD0bULqvb/yi6ZXgRls1ereq3OqnvA4JBLKx15O/jLayS/FhR4d/2vaeXuBOYXM7EGXItKkFxEXn3J+FCQPb5wY31GlbljrESjsiZ6gtrSmwryBluQCwMJ59LACzocxbWo42Kv3cpSig2aCu9CYXKC4sCH3eSKjwPtjdlpmX1VkYX5ge+JaZMn7A218ZgZOc9xpPawESOuIF9axcKW5PDEhOwmswFd2G65c8H9kJY6zEnqbArP9lRQMmjuAb011NILClaaRZOOupz2HZUdm+91Q==:' # rubocop:disable Layout/LineLength
        end

        it 'returns `400` (Bad Request)', :aggregate_failures do
          post '/activitypub/signature_required', params: 'Hello world', headers: {
            'Host' => 'www.example.com',
            'Content-Digest' => digest_header,
            'Signature-Input' => signature_input,
            'Signature' => signature_header,
          }

          expect(response).to have_http_status(400)
          expect(response.parsed_body).to match(
            error: 'Content-Digest could not be parsed. It does not contain a valid RFC8941 dictionary.'
          )
        end
      end
    end

    context 'with an inaccessible key' do
      let(:signature_input) do
        'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/alice#main-key"'
      end
      let(:signature_header) do
        'sig1=:WfM6q/qBqhUyqPUDt9metjadJGtLLpmMTBzk/t+R3byKe4/TGAXC6vBB/M6NsD5qv8GCmQGtisCMQxJQO0IGODGzi+Jv+eqDJ50agMVXNV6nUOzY44c4/XTPoI98qyx1oEMa4Hefy3vSYKq96iDVAc+RDLCMTeGP3wn9wizjD1SNmU0RZI1bTB+eCkywMP9mM5zXzUOYF+Qkuf+WdEpPR1XUGPlnqfdvPalcKVfaI/VThBjI91D/lmUGoa69x4EBEHM+aJmW6086e7/dVh+FndKkdGfXslZXFZKi2flTGQZgEWLn948SqAaJQROkJg8B14Sb1NONS1qZBhK3Mum8Pg==:' # rubocop:disable Layout/LineLength
      end

      before do
        stub_request(:get, 'https://remote.domain/users/alice#main-key').to_return(status: 404)
      end

      it 'fails to verify signature', :aggregate_failures do
        get '/activitypub/success', headers: {
          'Host' => 'www.example.com',
          'Signature-Input' => signature_input,
          'Signature' => signature_header,
        }

        expect(response.parsed_body).to match(
          signed_request: true,
          signature_actor_id: nil,
          error: 'Unable to fetch key JSON at https://remote.domain/users/alice#main-key'
        )
      end
    end
  end

  private

  def stub_tests_controller
    stub_const('ActivityPub::TestsController', activitypub_tests_controller)

    Rails.application.routes.draw do
      # NOTE: RouteSet#draw removes all routes, so we need to re-insert one
      resource :instance_actor, path: 'actor', only: [:show]

      match :via => [:get, :post], '/activitypub/success' => 'activitypub/tests#success'
      match :via => [:get, :post], '/activitypub/alternative-path' => 'activitypub/tests#alternative_success'
      match :via => [:get, :post], '/activitypub/signature_required' => 'activitypub/tests#signature_required'
    end
  end

  def activitypub_tests_controller
    Class.new(ApplicationController) do
      include SignatureVerification

      before_action :require_actor_signature!, only: [:signature_required]

      def success
        render json: {
          signed_request: signed_request?,
          signature_actor_id: signed_request_actor&.id&.to_s,
        }.merge(signature_verification_failure_reason || {})
      end

      alias_method :alternative_success, :success
      alias_method :signature_required, :success
    end
  end

  def digest_value(body)
    "SHA-256=#{Digest::SHA256.base64digest(body)}"
  end

  def build_signature_string(keypair, key_id, request_target, headers)
    algorithm = 'rsa-sha256'
    signed_headers = headers.merge({ '(request-target)' => request_target })
    signed_string = signed_headers.map { |key, value| "#{key.downcase}: #{value}" }.join("\n")
    signature = Base64.strict_encode64(keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))

    "keyId=\"#{key_id}\",algorithm=\"#{algorithm}\",headers=\"#{signed_headers.keys.join(' ').downcase}\",signature=\"#{signature}\""
  end
end
