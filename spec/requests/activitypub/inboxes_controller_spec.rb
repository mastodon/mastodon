# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::InboxesController do
  let!(:current_datetime) { 'Wed, 20 Dec 2023 10:00:00 GMT' }
  let!(:remote_actor_keypair) do
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
  let!(:remote_actor_inbox_url) { 'https://remote.domain/users/bob/inbox' }
  let!(:remote_actor_original_username) { 'original_username' }
  let!(:remote_actor) do
    Fabricate(:account,
              domain: 'remote.domain',
              uri: 'https://remote.domain/users/bob',
              private_key: nil,
              public_key: remote_actor_keypair.public_key.to_pem,
              username: remote_actor_original_username,
              protocol: :activitypub,
              inbox_url: remote_actor_inbox_url)
  end
  let!(:local_actor) { Fabricate(:account) }
  let!(:base_headers) do
    {
      'Host' => 'www.remote.domain',
      'Date' => current_datetime,
    }
  end
  let!(:note_content) { 'note from remote actor' }
  let!(:object_json) do
    {
      id: 'https://remote.domain/activities/objects/1',
      type: 'Note',
      content: note_content,
      to: ActivityPub::TagManager.instance.uri_for(local_actor),
    }
  end

  before do
    Sidekiq::Testing.inline!
    travel_to current_datetime
  end

  context 'when remote actor username has changed' do
    let(:remote_actor_new_username) { 'new_username' }
    let(:updated_remote_actor_json) do
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        id: remote_actor.uri,
        type: 'Person',
        preferredUsername: remote_actor_new_username,
        inbox: remote_actor.inbox_url,
        publicKey: {
          id: "#{remote_actor.uri}#main-key",
          owner: remote_actor.uri,
          publicKeyPem: remote_actor.public_key,
        },
      }.with_indifferent_access
    end

    before do
      stub_request(:get, 'https://remote.domain/users/bob#main-key')
        .to_return(
          body: updated_remote_actor_json.to_json,
          headers: {
            'Content-Type' => 'application/activity+json',
          },
          status: 200
        )
      stub_request(:get, 'https://remote.domain/users/bob')
        .to_return(
          body: updated_remote_actor_json.to_json,
          headers: {
            'Content-Type' => 'application/activity+json',
          },
          status: 200
        )
    end

    context 'with a create note' do
      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://remote.domain/activities/create/1',
          type: 'Create',
          actor: remote_actor.uri,
          object: object_json,
        }.with_indifferent_access
      end
      let(:digest_header) { digest_value(json.to_json) }
      let(:signature_header) do
        build_signature_string(
          remote_actor_keypair,
          'https://remote.domain/users/bob#main-key',
          "post /users/#{local_actor.username}/inbox",
          base_headers.merge(
            'Digest' => digest_header
          )
        )
      end
      let(:headers) do
        base_headers.merge(
          'Digest' => digest_header,
          'Signature' => signature_header
        )
      end

      it 'creates the note' do
        post "/users/#{local_actor.username}/inbox", params: json.to_json, headers: headers
        expect(response).to have_http_status(202)
        expect(Status.exists?(uri: object_json[:id])).to be(true)
      end

      it 'does not change the local record of the remote actor' do
        post "/users/#{local_actor.username}/inbox", params: json.to_json, headers: headers
        expect(remote_actor.reload.username).to eq(remote_actor_original_username)
      end
    end

    context 'with an update actor' do
      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'https://remote.domain/activities/update/1',
          type: 'Update',
          actor: remote_actor.uri,
          object: updated_remote_actor_json,
        }.with_indifferent_access
      end
      let(:digest_header) { digest_value(json.to_json) }
      let(:signature_header) do
        build_signature_string(
          remote_actor_keypair,
          'https://remote.domain/users/bob#main-key',
          "post /users/#{local_actor.username}/inbox",
          base_headers.merge(
            'Digest' => digest_header
          )
        )
      end
      let(:headers) do
        base_headers.merge(
          'Digest' => digest_header,
          'Signature' => signature_header
        )
      end

      it 'does not increase the number of accounts' do
        expect do
          post "/users/#{local_actor.username}/inbox", params: json.to_json, headers: headers
        end.to(not_change { Account.count })
      end

      it 'does not update the remote actors username' do
        post "/users/#{local_actor.username}/inbox", params: json.to_json, headers: headers
        expect(response).to have_http_status(202)
        expect(remote_actor.reload.username).to eq(remote_actor_original_username)
      end
    end
  end
end
