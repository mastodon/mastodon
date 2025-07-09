# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Statuses' do
  describe 'GET /@:account_username/:id' do
    let(:account) { Fabricate(:account) }
    let(:status)  { Fabricate(:status, account: account) }

    context 'when signed out' do
      context 'when account is permanently suspended' do
        before do
          account.suspend!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          get "/@#{account.username}/#{status.id}"

          expect(response)
            .to have_http_status(410)
        end
      end

      context 'when account is temporarily suspended' do
        before { account.suspend! }

        it 'returns http forbidden' do
          get "/@#{account.username}/#{status.id}"

          expect(response)
            .to have_http_status(403)
        end
      end

      context 'when status is a reblog' do
        let(:original_account) { Fabricate(:account, domain: 'example.com') }
        let(:original_status) { Fabricate(:status, account: original_account, url: 'https://example.com/123') }
        let(:status) { Fabricate(:status, account: account, reblog: original_status) }

        it 'redirects to the original status' do
          get "/@#{status.account.username}/#{status.id}"

          expect(response)
            .to redirect_to(original_status.url)
        end
      end

      context 'when status visibility is public' do
        subject { get short_account_status_path(account_username: account.username, id: status.id, format: format) }

        let(:status) { Fabricate(:status, account: account, visibility: :public) }

        context 'with HTML' do
          let(:format) { 'html' }

          it 'renders status successfully', :aggregate_failures do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.headers).to include(
              'Vary' => 'Accept, Accept-Language, Cookie',
              'Cache-Control' => include('public'),
              'Link' => include('activity+json')
            )
            expect(response.body)
              .to include(status.text)
          end
        end

        context 'with JSON' do
          let(:format) { 'json' }

          it 'renders ActivityPub Note object successfully', :aggregate_failures do
            subject

            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')

            expect(response.headers).to include(
              'Content-Type' => include('application/activity+json'),
              'Link' => include('activity+json')
            )
            expect(response.parsed_body)
              .to include(content: include(status.text))
          end
        end
      end

      context 'when status visibility is private' do
        let(:status) { Fabricate(:status, account: account, visibility: :private) }

        it 'returns http not found' do
          get short_account_status_path(account_username: account.username, id: status.id)

          expect(response)
            .to have_http_status(404)
        end
      end

      context 'when status visibility is direct' do
        let(:status) { Fabricate(:status, account: account, visibility: :direct) }

        it 'returns http not found' do
          get short_account_status_path(account_username: account.username, id: status.id)

          expect(response)
            .to have_http_status(404)
        end
      end
    end

    context 'when signed in' do
      subject { get short_account_status_path(account_username: account.username, id: status.id, format: format) }

      let(:user) { Fabricate(:user) }

      before { sign_in_with_session(user) }

      context 'when account blocks user' do
        before { account.block!(user.account) }

        it 'returns http not found' do
          get "/@#{status.account.username}/#{status.id}"

          expect(response)
            .to have_http_status(404)
        end
      end

      context 'when status is public' do
        context 'with HTML' do
          let(:format) { 'html' }

          it 'renders status successfully', :aggregate_failures do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.headers).to include(
              'Vary' => 'Accept, Accept-Language, Cookie',
              'Cache-Control' => include('private'),
              'Link' => include('activity+json')
            )
            expect(response.body)
              .to include(status.text)
          end
        end

        context 'with JSON' do
          let(:format) { 'json' }

          it 'renders ActivityPub Note object successfully', :aggregate_failures do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.headers).to include(
              'Vary' => 'Accept, Accept-Language, Cookie',
              'Cache-Control' => include('private'),
              'Content-Type' => include('application/activity+json'),
              'Link' => include('activity+json')
            )
            expect(response.parsed_body)
              .to include(content: include(status.text))
          end
        end
      end

      context 'when status is private' do
        let(:status) { Fabricate(:status, account: account, visibility: :private) }

        context 'when user is authorized to see it' do
          before { user.account.follow!(account) }

          context 'with HTML' do
            let(:format) { 'html' }

            it 'renders status successfully', :aggregate_failures do
              subject

              expect(response)
                .to have_http_status(200)

              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Link' => include('activity+json')
              )
              expect(response.body)
                .to include(status.text)
            end
          end

          context 'with JSON' do
            let(:format) { 'json' }

            it 'renders ActivityPub Note object successfully', :aggregate_failures do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Content-Type' => include('application/activity+json'),
                'Link' => include('activity+json')
              )
              expect(response.parsed_body)
                .to include(content: include(status.text))
            end
          end
        end

        context 'when user is not authorized to see it' do
          let(:format) { 'html' }

          it 'returns http not found' do
            subject

            expect(response)
              .to have_http_status(404)
          end
        end
      end

      context 'when status is direct' do
        let(:status) { Fabricate(:status, account: account, visibility: :direct) }

        context 'when user is authorized to see it' do
          before { Fabricate(:mention, account: user.account, status: status) }

          context 'with HTML' do
            let(:format) { 'html' }

            it 'renders status successfully', :aggregate_failures do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Link' => include('activity+json')
              )
              expect(response.body)
                .to include(status.text)
            end
          end

          context 'with JSON' do
            let(:format) { 'json' }

            it 'renders ActivityPub Note object successfully' do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Content-Type' => include('application/activity+json'),
                'Link' => include('activity+json')
              )
              expect(response.parsed_body)
                .to include(content: include(status.text))
            end
          end
        end

        context 'when user is not authorized to see it' do
          let(:format) { 'html' }

          it 'returns http not found' do
            subject

            expect(response)
              .to have_http_status(404)
          end
        end
      end

      private

      def sign_in_with_session(user)
        # The regular `sign_in` helper does not actually set session cookies
        # The endpoint responses here rely on cookie/session checks to set cache privacy headers
        # To enable that, perform a full sign in which will establish those cookies for subsequent spec requests
        post user_session_path, params: { user: { email: user.email, password: user.password } }
      end
    end

    context 'with "HTTP Signature" access signed by a remote account' do
      subject do
        get short_account_status_path(account_username: status.account.username, id: status.id, format: format),
            headers: nil,
            sign_with: remote_account
      end

      let(:format) { 'html' }
      let(:remote_account) { Fabricate(:account, domain: 'host.example') }

      context 'when account blocks the remote account' do
        before { account.block!(remote_account) }

        it 'returns http not found' do
          subject

          expect(response)
            .to have_http_status(404)
        end
      end

      context 'when account domain blocks the domain of the remote account' do
        before { account.block_domain!(remote_account.domain) }

        it 'returns http not found' do
          subject

          expect(response)
            .to have_http_status(404)
        end
      end

      context 'when status has public visibility' do
        context 'with HTML' do
          let(:format) { 'html' }

          it 'renders status successfully', :aggregate_failures do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.headers).to include(
              'Vary' => 'Accept, Accept-Language, Cookie',
              'Cache-Control' => include('private'),
              'Link' => include('activity+json')
            )
            expect(response.body)
              .to include(status.text)
          end
        end

        context 'with JSON' do
          let(:format) { 'json' }

          it 'renders ActivityPub Note object successfully', :aggregate_failures do
            subject

            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')
            expect(response.headers).to include(
              'Content-Type' => include('application/activity+json'),
              'Link' => include('activity+json')
            )
            expect(response.parsed_body)
              .to include(content: include(status.text))
          end
        end
      end

      context 'when status has private visibility' do
        let(:status) { Fabricate(:status, account: account, visibility: :private) }

        context 'when user is authorized to see it' do
          before { remote_account.follow!(account) }

          context 'with HTML' do
            let(:format) { 'html' }

            it 'renders status successfully', :aggregate_failures do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Link' => include('activity+json')
              )
              expect(response.body)
                .to include(status.text)
            end
          end

          context 'with JSON' do
            let(:format) { 'json' }

            it 'renders ActivityPub Note object successfully' do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Content-Type' => include('application/activity+json'),
                'Link' => include('activity+json')
              )

              expect(response.parsed_body)
                .to include(content: include(status.text))
            end
          end
        end

        context 'when user is not authorized to see it' do
          it 'returns http not found' do
            subject

            expect(response)
              .to have_http_status(404)
          end
        end
      end

      context 'when status is direct' do
        let(:status) { Fabricate(:status, account: account, visibility: :direct) }

        context 'when user is authorized to see it' do
          before { Fabricate(:mention, account: remote_account, status: status) }

          context 'with HTML' do
            let(:format) { 'html' }

            it 'renders status successfully', :aggregate_failures do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Link' => include('activity+json')
              )
              expect(response.body)
                .to include(status.text)
            end
          end

          context 'with JSON' do
            let(:format) { 'json' }

            it 'renders ActivityPub Note object', :aggregate_failures do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.headers).to include(
                'Vary' => 'Accept, Accept-Language, Cookie',
                'Cache-Control' => include('private'),
                'Content-Type' => include('application/activity+json'),
                'Link' => include('activity+json')
              )
              expect(response.parsed_body)
                .to include(content: include(status.text))
            end
          end
        end

        context 'when user is not authorized to see it' do
          it 'returns http not found' do
            subject

            expect(response)
              .to have_http_status(404)
          end
        end
      end
    end
  end
end
