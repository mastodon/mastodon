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
      let!(:actor) { Fabricate(:account, username: 'bob', domain: 'remote.domain', uri: 'https://remote.domain/users/bob', public_key: actor_keypair.public_key.to_pem, protocol: :activitypub) }

      let(:actor_json) do
        {
          '@context': [
            'https://www.w3.org/ns/activitystreams',
            'https://w3id.org/security/v1',
          ],
          id: ActivityPub::TagManager.instance.uri_for(actor),
          type: 'Person',
          preferredUsername: 'bob',
          inbox: 'https://remote.domain/inbox',
          publicKey: {
            id: 'https://remote.domain/users/bob#main-key',
            owner: 'https://remote.domain/users/bob',
            publicKeyPem: actor_keypair.public_key.to_pem,
          },
        }
      end

      context 'with an acct key ID' do
        let(:signature_header) do
          'keyId="acct:bob@remote.domain",algorithm="rsa-sha256",headers="date host (request-target)",signature="Z8ilar3J7bOwqZkMp7sL8sRs4B1FT+UorbmvWoE+A5UeoOJ3KBcUmbsh+k3wQwbP5gMNUrra9rEWabpasZGphLsbDxfbsWL3Cf0PllAc7c1c7AFEwnewtExI83/qqgEkfWc2z7UDutXc2NfgAx89Ox8DXU/fA2GG0jILjB6UpFyNugkY9rg6oI31UnvfVi3R7sr3/x8Ea3I9thPvqI2byF6cojknSpDAwYzeKdngX3TAQEGzFHz3SDWwyp3jeMWfwvVVbM38FxhvAnSumw7YwWW4L7M7h4M68isLimoT3yfCn2ucBVL5Dz8koBpYf/40w7QidClAwCafZQFC29yDOg=="' # rubocop:disable Layout/LineLength
        end

        it 'successfuly verifies signature', :aggregate_failures do
          expect(signature_header).to eq build_signature_string(actor_keypair, 'acct:bob@remote.domain', 'get /activitypub/success', { 'Date' => 'Wed, 20 Dec 2023 10:00:00 GMT', 'Host' => 'www.example.com' })

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

        context 'when the key material has changed' do
          # Let the user be known with the default test keys
          let!(:actor) { Fabricate(:account, username: 'bob', domain: 'remote.domain', uri: 'https://remote.domain/users/bob', protocol: :activitypub) }

          # Needed to update the keypair
          before { stub_key_requests }

          it 'successfuly verifies signature after refreshing the account', :aggregate_failures do
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

        # Signature verification will fail, so the key will be refetched
        before { stub_key_requests }

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
        # Signature verification will fail, so the key will be refetched
        before { stub_key_requests }

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
        # Signature verification will fail, so the key will be refetched
        before { stub_key_requests }

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
      let!(:actor) { Fabricate(:account, domain: 'remote.domain', uri: 'https://remote.domain/users/bob', public_key: actor_keypair.public_key.to_pem) }

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

    context 'with a Ed25519 key' do
      # Include the private key so the tests can be easily adjusted and reviewed
      let(:actor_keypair) do
        OpenSSL::PKey.read(<<~PEM_TEXT)
          -----BEGIN PRIVATE KEY-----
          MC4CAQAwBQYDK2VwBCIEIE4+t/Xnl3lEh/Uw72qW2IWlMQJOHaLuFUipMUHPfO2M
          -----END PRIVATE KEY-----
        PEM_TEXT
      end

      context 'with a known account' do
        let!(:actor) { Fabricate(:account, domain: 'remote.domain', uri: 'https://remote.domain/users/bob') }

        before do
          Fabricate(:keypair, account: actor, type: :ed25519, public_key: actor_keypair.public_to_pem, uri: 'https://remote.domain/users/bob#main-key')
        end

        context 'with a valid signature on a GET request' do
          let(:signature_input) do
            'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
          end
          let(:signature_header) do
            'sig1=:o5DKH6Bge3pkaSs4UHqa1lMmbzTyBKOrDkILRA7OQ4La2d1HgM2CbIhi30KwemP+Jd5tgSv8NL65/H+57QbwDQ==:'
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
      end
    end

    context 'with a ML-DSA-44 key', skip: 'waiting for ubuntu-26.04 runners' do
      # Include the private key so the tests can be easily adjusted and reviewed
      let(:actor_keypair) do
        OpenSSL::PKey.read(<<~PEM_TEXT)
          -----BEGIN PRIVATE KEY-----
          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
          -----END PRIVATE KEY-----
        PEM_TEXT
      end

      context 'with a known account' do
        let!(:actor) { Fabricate(:account, domain: 'remote.domain', uri: 'https://remote.domain/users/bob') }

        before do
          Fabricate(:keypair, account: actor, type: :'ml-dsa-44', public_key: actor_keypair.public_to_pem, uri: 'https://remote.domain/users/bob#main-key')
        end

        context 'with a valid signature on a GET request' do
          let(:signature_input) do
            'sig1=("@method" "@target-uri");created=1703066400;keyid="https://remote.domain/users/bob#main-key"'
          end
          let(:signature_header) do
            'sig1=:wDbo3JFnNiykwXqOHegFhqI0R4hKFUcU/7nHezcxXA74ztrG912ykoQgXgom8F8NbgrqEDGJ2VaTeYLNdml05qGcTTb52O+be8UTzv0UjJAe21CN4ftWwSxz5ZzKOOXXKl9brRJn4ZsdsHVieo4X5r6RjNp/SyoWEeP0Jo63+tpxQ5uogn6dte+AiOhsGVV1NS6pG0ebaP6/fV+xfmDY8T+3eY0PpSmpXdfxk9unm7N5ONyH/WFQyuFFQJgVRFZdEXiuyCo3xYbZlLiUM/+pyF7NfaMsOSEC2ZBuLRiuSp1ZBazDnFvaRqkqKLjbiVsw9qrtYNWJBwO/LkkRpQfM17CaZyZhebUawqcNVDALKkoOahvSN83yOU2zOHRys6NbpHmzCe4JLx8/OeKURgTclPwyfGQ1eP0vdi0AomKI2Y+pn8FpSHE1eBW5GIfayKPSZp/tcxQ86MpHuGPXBuZtttARiArZaZ6SZJDCQ2K13jTs4YIOZnLU70mT3/dFztRtufDIVfrexTZoIJ2UuVJ4FnRleOTpfBsgEdkmlX4k1E99BfC5giKEHuOcJv7Gl1x7ZvSqjEW55klqJh+dSrBTqfiOjZSysiUO2rhaRY8MoycZitFk8y8XBCxi6/+9gl3lvxAQ3gHwE4t6QWqCZNSDPDWPd/aAed4fGHhf32s9nzz+nnjEJ+3FWh7mz/jZjzqqDrqrf8kU9eix95b4/4vBIau/E4XxTESY2g7a3VHlrMBg7f6w7XpSZ9DT8356G9XvlaYRCAXtXbJcRIiHEMDftF8mFTH/LZuDNfZWXLpwYANd8DXKjmw8mNK1pVYidPPnRLANqhIF1BLnZv5QaJN2lAkv8pl/zunN9M1a3IhCV6fcsu3zLJJiQcZ0FDLXzn+nAaQz3mBbJDv8rLUBI0xolYGeOohP4zKGIa7F9zZtvHc71g2L2LUYuWJJztni7m+ReOib5NHoI5vinAZQbYILIW/2E7AP/4d4O/UOusYFiWIdC0UF1hnrlZM4CnCKlz9x4SQ7XhY5t1oNHd0HWa3/fkZWFn/0hjC5VWA8SQ4fqvcxD4oqw3k4M2NUDtQEw2jK968s4zkLzO5GrOx3XNscY1hgGJn7JPYhuXlMTIhBjZa4X9n1qTwO/LS+oDnbGCXbUFErCzJAaBdP3KjwufI2tgUxr+AUJES95G6MVFalllDheJnZDiH5SgahX0omvPAryFWqaRnqXQsqZUXrTRmj0yeGFHsrvgMo46l28zVMZcZBBgZ7v4kI1z6qYRT4TwNliHVZyi0/rBeQERvLC+8e0ergX9TdYT2t3+uekUhlxT5Z/tNsSQ3HJJ3dStSdKasLfmoEIrZ1khGSaLi8+2BkkZhLvGzfl0+nDpPGEKhyJTVNmr62a4jROcPEuMWq3C2CXuwxtAOM2X1ZZvAYNYq4A/ktFU5t9W4WNZpbOr8jgRhkZ62lLYfM7BZ9PZ0CYBGrYIOyUHsmd2Dw7/a8jr74+uUA51I4jkrdBYjJcV2g0GdsFMTkZNcHO17RVtn877Y6QyKeqpei/6C38fKHDT4osvv3hxRe8G8t8HDTtjIu183h5ZY00evs7qSTbs4qd7vW+k2iW2QEWur/1hVIwhk8E2n+jabyZwB3FcuNjB/DvxXIaWafJuAj9nS44iffuIvmX0RncVusjP93x+msQaCfKJZI2DmmBJD+CcjD10BzCPJyIM/++gBiswY9LEhyhpEYGH0dey5ygxlazMFp1wzgUrJ/JN48/Bs1IEo7lwGg5LCitVH/ahh6sEgXQsom64ZoBRyjg/uafaU8idZQCo54lql0eXaPA10E/gn1ORpWQ1KD+NfVdXPS9cJSqgQKy75vFHwS+neq3mSyoboBHpPlK1xU4TOt59uKP7XIRDXQ1FB8XyoaaEAS28TbRz7o09tnfMvePJs2xJ8ONyJ3PZosdl745gs/8gkv80S1NeFZdwC37btLjH9hR7TCZLB6y7PT3TRQsbIOqOmvzVZVqx/UsxL4h9I6URsm8G4d6+WaNwU6fAtvX2m6PUPZSnpzDVL1Dndj+QWE3kyACxr8a7R6HxrGcVRbQ1MDoMFyZdW5JUWUjCrkDKArNURcOSizmDON0h+LS0ku4fdb98+oHcSAkE6dpHloI8aBCCS2XDQs94jiwrTQZ0FazmyIZeF9Ve9RKycxGuVgFYDbSoEWn3Q1DhrXjbblv9V91YmdyDkYE75uA25C13HDtybPFnwoE59ypiMZanegJHR0UiqlKi4YJk5/2B7JE7+Oq63I6d0T2uh96g6ba/vez+bCMtdJydaZ/c/z+lCJn5sI/Fl2vWjAN6talXSA57l40Se363VITc9w3V/KiaOBL1bBXF7LL9aec/YR0s5Sostyahbasi96aZV73vIhxsk54pcJvbzGaHzEEv6dUwPHBvRfKY/sEOBKaObAPHp8AmTbOd8Z/YfMpae5XcGF7IJz0Yhr3nKLi/NKYsBnm090ozgf1BSatshCikEGr4yK4YeoiZB1iKCbcspbY055JD855z03AQR9wAMs8PZ6IdVRYywyHnRapQEPc9NLrNeanQM2rzK5wEAZ1txjLbZC2IzskFBuqCBQd5WlL/U634Cj1K8KPpWJ26SyelbuynFykgwzfejFdctq19ZtANEzjbxFUdPurIlT/74q+Jxjt0y6PW3izYaqmseTwroI5DO/WqjNzykc3gB6rxwUxhLQ/6R1on8Np43lc2g8/x9u8jyPPmKA9NlzPT0UhoiBDQhr17g4jsj5VQ4oLpZ66paQYgaJhHA57wbOfouqmMkE6gnxgUIVCu6mDfgaXYmvXTdZfrS0kosubLvcubpVyQRcvqWmziQqxVVIIzPMGC2dZBS7HbhzwZw+k7kowELKgxsw1oiL6DyHuDbuqX3rPmVihrmCkzjdtvfM3xR25xbU6iCsnn1vuG7KM20U+9q/vy3pgKJmXZAq69dHVfDI1ficwC665VLeBP57eu5zQgkxz7q5kJZPw12ePPqVVaN93r6KUxj4sS3nFmYI+ZIZELbKfrau5cmtcix3gNeoe/sSmlUKy19w6FysaP1oKedED8pOeei7yCgw7hC7wL+1MXWIS0P+9q/uIJr/hIgJGzVYeXuRmaayyMzrAAwYHy8xOkZIUFeGr7a4vO7xGDFNY21xc5GbucHR2PUEFBcqMkaLqMnQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0fLTc=:' # rubocop:disable Layout/LineLength
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

  def stub_key_requests
    stub_request(:get, 'https://remote.domain/users/bob').to_return(status: 200, body: actor_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
    stub_request(:get, 'https://remote.domain/users/bob#main-key').to_return(status: 200, body: actor_json.to_json, headers: { 'Content-Type': 'application/activity+json' })
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
