# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Following accounts' do
  let(:account) { Fabricate(:account, username: 'alice') }

  describe 'GET /users/:username/following' do
    it 'redirects to the canonical URL' do
      get account_following_index_path(account)

      expect(response)
        .to redirect_to("/@#{account.username}/following")
        .and have_http_status(301)
    end
  end

  describe 'GET /@:username/following' do
    subject { get "/@#{account.username}/following", params: { page: page }, as: format }

    let(:format) { :html }
    let(:page) { nil }

    shared_examples 'unavailable account responses' do
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

      context 'when account is permanently deleted' do
        before do
          account.mark_deleted!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          subject

          expect(response)
            .to have_http_status(410)
        end
      end

      context 'when account is pending deletion' do
        before { account.mark_deleted! }

        it 'returns http forbidden' do
          subject

          expect(response)
            .to have_http_status(403)
        end
      end
    end

    context 'with HTML' do
      it_behaves_like 'unavailable account responses'
    end

    context 'with JSON' do
      let(:format) { :json }
      let(:followee_bob) { Fabricate(:account, username: 'bob') }
      let(:followee_chris) { Fabricate(:account, username: 'chris') }

      before do
        account.follow!(followee_bob)
        account.follow!(followee_chris)
      end

      context 'with page' do
        let(:page) { 1 }

        it 'returns followed accounts' do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.parsed_body)
            .to include(
              orderedItems: contain_exactly(
                ActivityPub::TagManager.instance.uri_for(followee_bob),
                ActivityPub::TagManager.instance.uri_for(followee_chris)
              ),
              totalItems: eq(2),
              partOf: be_present
            )
        end

        context 'when account hides their network' do
          before { account.update(hide_collections: true) }

          it 'returns forbidden response' do
            subject

            expect(response)
              .to have_http_status(403)
            expect(response.parsed_body)
              .to include(error: /forbidden/i)
          end
        end

        context 'when signed in and blocking an account' do
          let(:user) { Fabricate(:user) }

          before do
            Fabricate :block, account: user.account, target_account: followee_bob
            sign_in user
          end

          it 'returns followed accounts without blocked accounts' do
            subject

            expect(response)
              .to have_http_status(200)
            expect(response.parsed_body)
              .to include(
                orderedItems: contain_exactly(
                  ActivityPub::TagManager.instance.uri_for(followee_chris)
                )
              )
          end
        end

        it_behaves_like 'unavailable account responses'
      end

      context 'without page' do
        it 'returns the following collection' do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.parsed_body)
            .to include(totalItems: eq(2))
            .and not_include(:partOf)
        end

        context 'when account hides their network' do
          before { account.update(hide_collections: true) }

          it 'returns following count but not any items' do
            subject

            expect(response.parsed_body)
              .to include(totalItems: eq(2))
              .and not_include(:items, :orderedItems, :first, :last)
          end
        end

        it_behaves_like 'unavailable account responses'
      end
    end
  end
end
