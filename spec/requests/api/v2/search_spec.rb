# frozen_string_literal: true

require 'rails_helper'

describe 'Search API' do
  context 'with token' do
    let(:user)    { Fabricate(:user) }
    let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
    let(:scopes)  { 'read:search' }
    let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

    describe 'GET /api/v2/search' do
      let!(:bob)   { Fabricate(:account, username: 'bob_test') }
      let!(:ana)   { Fabricate(:account, username: 'ana_test') }
      let!(:tom)   { Fabricate(:account, username: 'tom_test') }
      let(:params) { { q: 'test' } }

      it 'returns http success' do
        get '/api/v2/search', headers: headers, params: params

        expect(response).to have_http_status(200)
      end

      context 'when searching accounts' do
        let(:params) { { q: 'test', type: 'accounts' } }

        it 'returns all matching accounts' do
          get '/api/v2/search', headers: headers, params: params

          expect(body_as_json[:accounts].pluck(:id)).to contain_exactly(bob.id.to_s, ana.id.to_s, tom.id.to_s)
        end

        context 'with truthy `resolve`' do
          let(:params) { { q: 'test1', resolve: '1' } }

          it 'returns http unauthorized' do
            get '/api/v2/search', headers: headers, params: params

            expect(response).to have_http_status(200)
          end
        end

        context 'with valid `offset` value' do
          let(:params) { { q: 'test1', offset: 1 } }

          it 'returns http unauthorized' do
            get '/api/v2/search', headers: headers, params: params

            expect(response).to have_http_status(200)
          end
        end

        context 'with negative `offset` value' do
          let(:params) { { q: 'test1', offset: '-100', type: 'accounts' } }

          it 'returns http bad_request' do
            get '/api/v2/search', headers: headers, params: params

            expect(response).to have_http_status(400)
          end
        end

        context 'with negative `limit` value' do
          let(:params) { { q: 'test1', limit: '-100', type: 'accounts' } }

          it 'returns http bad_request' do
            get '/api/v2/search', headers: headers, params: params

            expect(response).to have_http_status(400)
          end
        end

        context 'with following=true' do
          let(:params) { { q: 'test', type: 'accounts', following: 'true' } }

          before do
            user.account.follow!(ana)
          end

          it 'returns only the followed accounts' do
            get '/api/v2/search', headers: headers, params: params

            expect(body_as_json[:accounts].pluck(:id)).to contain_exactly(ana.id.to_s)
          end
        end

        context 'when a remote actor username has changed' do
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
                      protocol: 1, # activitypub
                      inbox_url: remote_actor_inbox_url)
          end
          let!(:remote_actor_old_handle) { "#{remote_actor_original_username}@remote.domain" }
          let!(:remote_actor_new_username) { 'new_username' }
          let!(:remote_actor_json) do
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
          let!(:remote_actor_new_handle) { "#{remote_actor_new_username}@remote.domain" }
          let(:webfinger_response) do
            {
              subject: "acct:#{remote_actor_new_handle}",
              links: [
                {
                  rel: 'self',
                  type: 'application/activity+json',
                  href: remote_actor.uri,
                },
              ],
            }
          end

          before do
            sign_in(user)
            tom.follow!(remote_actor)
            stub_request(:get, "https://remote.domain/.well-known/webfinger?resource=acct:#{remote_actor_new_handle}")
              .to_return(
                body: webfinger_response.to_json,
                headers: {
                  'Content-Type' => 'application/json',
                },
                status: 200
              )
            stub_request(:get, remote_actor.uri)
              .to_return(
                body: remote_actor_json.to_json,
                headers: {
                  'Content-Type' => 'application/activity+json',
                },
                status: 200
              )
            Sidekiq::Testing.inline!
          end

          context 'when requesting the old handle' do
            let!(:params) { { q: remote_actor_old_handle, resolve: '1' } }

            it 'does not increase the number of accounts' do
              expect do
                get '/api/v2/search', headers: headers, params: params
              end.to(not_change { Account.count })
            end

            it 'does not change the remote actor account' do
              get '/api/v2/search', headers: headers, params: params
              expect(remote_actor.reload.username).to eq(remote_actor_original_username)
            end

            it 'returns the remote actor account' do
              get '/api/v2/search', headers: headers, params: params
              expect(body_as_json[:accounts].pluck(:id)).to contain_exactly(remote_actor.id.to_s)
            end
          end

          context 'when requesting the old handle of a stale account' do
            let!(:params) { { q: remote_actor_old_handle, resolve: '1' } }

            before do
              stub_request(:get, 'https://remote.domain/.well-known/host-meta').to_return(status: 404)
              remote_actor.update(last_webfingered_at: 2.days.ago)
            end

            it 'makes a webfinger request with the old handle' do
              stub_request(:get, "https://remote.domain/.well-known/webfinger?resource=acct:#{remote_actor_old_handle}")
              get '/api/v2/search', headers: headers, params: params
              expect(
                a_request(
                  :get,
                  "https://remote.domain/.well-known/webfinger?resource=acct:#{remote_actor_old_handle}"
                )
              ).to have_been_made.once
            end

            it 'does nothing if the webfinger request returns not found' do
              stub_request(:get, "https://remote.domain/.well-known/webfinger?resource=acct:#{remote_actor_old_handle}")
                .to_return(
                  status: 404
                )
              get '/api/v2/search', headers: headers, params: params
              expect(body_as_json[:accounts].empty?).to be(true)
              expect(remote_actor.reload.username).to eq(remote_actor_original_username)
            end

            it 'merges the old account with the new account if the webfinger request succeeds' do
              stub_request(:get, "https://remote.domain/.well-known/webfinger?resource=acct:#{remote_actor_old_handle}")
                .to_return(
                  body: {
                    subject: "acct:#{remote_actor_old_handle}",
                    links: [
                      {
                        rel: 'self',
                        type: 'application/activity+json',
                        href: remote_actor.uri,
                      },
                    ],
                  }.to_json,
                  headers: {
                    'Content-Type' => 'application/json',
                  },
                  status: 200
                )
              expect do
                get '/api/v2/search', headers: headers, params: params
              end.to(not_change { Account.count })

              expect(Account.exists?(id: remote_actor.id)).to be(false)
              new_remote_actor = Account.find_by(
                uri: remote_actor.uri,
                username: remote_actor_new_username
              )
              expect(new_remote_actor.present?).to be(true)
              expect(tom.following?(new_remote_actor)).to be(true)
            end
          end

          context 'when requesting the new handle' do
            let(:params) { { q: remote_actor_new_handle, resolve: '1' } }

            it 'does not increase the number of accounts' do
              expect do
                get '/api/v2/search', headers: headers, params: params
              end.to(not_change { Account.count })
            end

            it 'merges the old account with the new account' do
              get '/api/v2/search', headers: headers, params: params
              expect(Account.exists?(id: remote_actor.id)).to be(false)
              new_remote_actor = Account.find_by(
                uri: remote_actor.uri,
                username: remote_actor_new_username
              )
              expect(new_remote_actor.present?).to be(true)
              expect(tom.following?(new_remote_actor)).to be(true)
            end
          end
        end
      end

      context 'when search raises syntax error' do
        before { allow(Search).to receive(:new).and_raise(Mastodon::SyntaxError) }

        it 'returns http unprocessable_entity' do
          get '/api/v2/search', headers: headers, params: params

          expect(response).to have_http_status(422)
        end
      end

      context 'when search raises not found error' do
        before { allow(Search).to receive(:new).and_raise(ActiveRecord::RecordNotFound) }

        it 'returns http not_found' do
          get '/api/v2/search', headers: headers, params: params

          expect(response).to have_http_status(404)
        end
      end
    end
  end

  context 'without token' do
    describe 'GET /api/v2/search' do
      let(:search_params) { nil }

      before do
        get '/api/v2/search', params: search_params
      end

      context 'without a `q` param' do
        it 'returns http bad_request' do
          expect(response).to have_http_status(400)
        end
      end

      context 'with a `q` shorter than 5 characters' do
        let(:search_params) { { q: 'test' } }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end
      end

      context 'with a `q` equal to or longer than 5 characters' do
        let(:search_params) { { q: 'test1' } }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        context 'with truthy `resolve`' do
          let(:search_params) { { q: 'test1', resolve: '1' } }

          it 'returns http unauthorized' do
            expect(response).to have_http_status(401)
            expect(response.body).to match('resolve remote resources')
          end
        end

        context 'with `offset`' do
          let(:search_params) { { q: 'test1', offset: 1 } }

          it 'returns http unauthorized' do
            expect(response).to have_http_status(401)
            expect(response.body).to match('pagination is not supported')
          end
        end
      end
    end
  end
end
