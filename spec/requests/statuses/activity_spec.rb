# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Status Activity' do
  describe 'GET /users/:account_username/statuses/:id/activity' do
    let(:account) { Fabricate(:account) }
    let(:status)  { Fabricate(:status, account: account) }

    context 'when signed out' do
      subject { get activity_account_status_path(account.username, status) }

      context 'when account is permanently suspended' do
        before do
          account.suspend!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          subject

          expect(response)
            .to have_http_status(410)
        end
      end

      context 'when account is temporarily suspended' do
        before { account.suspend! }

        it 'returns http forbidden' do
          subject

          expect(response)
            .to have_http_status(403)
        end
      end

      context 'when status is public' do
        before { status.update(visibility: :public) }

        it 'returns http success' do
          subject

          expect(response)
            .to have_http_status(:success)
          expect(response.content_type)
            .to start_with('application/activity+json')
        end
      end

      context 'when status is private' do
        before { status.update(visibility: :private) }

        it 'returns http not_found' do
          subject

          expect(response)
            .to have_http_status(404)
        end
      end

      context 'when status is direct' do
        before { status.update(visibility: :direct) }

        it 'returns http not_found' do
          subject

          expect(response)
            .to have_http_status(404)
        end
      end
    end

    context 'when signed in' do
      subject { get activity_account_status_path(account.username, status) }

      let(:user) { Fabricate(:user) }

      before { sign_in(user) }

      context 'when status is public' do
        before { status.update(visibility: :public) }

        it 'returns http success' do
          subject

          expect(response)
            .to have_http_status(:success)
          expect(response.content_type)
            .to start_with('application/activity+json')
        end
      end

      context 'when status is private' do
        before { status.update(visibility: :private) }

        context 'when user is authorized to see it' do
          before { user.account.follow!(account) }

          it 'returns http success' do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.content_type)
              .to start_with('application/activity+json')
          end
        end

        context 'when user is not authorized to see it' do
          it 'returns http not_found' do
            subject

            expect(response)
              .to have_http_status(404)
          end
        end
      end

      context 'when status is direct' do
        before { status.update(visibility: :direct) }

        context 'when user is authorized to see it' do
          before { Fabricate(:mention, account: user.account, status: status) }

          it 'returns http success' do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.content_type)
              .to start_with('application/activity+json')
          end
        end

        context 'when user is not authorized to see it' do
          it 'returns http not_found' do
            subject

            expect(response)
              .to have_http_status(404)
          end
        end
      end
    end

    context 'with signature' do
      subject { get activity_account_status_path(account.username, status), headers: nil, sign_with: remote_account }

      let(:remote_account) { Fabricate(:account, domain: 'example.com') }

      context 'when status is public' do
        before { status.update(visibility: :public) }

        it 'returns http success' do
          subject

          expect(response)
            .to have_http_status(:success)
          expect(response.content_type)
            .to start_with('application/activity+json')
        end
      end

      context 'when status is private' do
        before { status.update(visibility: :private) }

        context 'when user is authorized to see it' do
          before { remote_account.follow!(account) }

          it 'returns http success' do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.content_type)
              .to start_with('application/activity+json')
          end
        end

        context 'when user is not authorized to see it' do
          it 'returns http not_found' do
            subject

            expect(response)
              .to have_http_status(404)
          end
        end
      end

      context 'when status is direct' do
        before { status.update(visibility: :direct) }

        context 'when user is authorized to see it' do
          before { Fabricate(:mention, account: remote_account, status: status) }

          it 'returns http success' do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.content_type)
              .to start_with('application/activity+json')
          end
        end

        context 'when user is not authorized to see it' do
          it 'returns http not_found' do
            subject

            expect(response)
              .to have_http_status(404)
          end
        end
      end
    end
  end
end
