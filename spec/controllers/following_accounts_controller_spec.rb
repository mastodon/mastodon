# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowingAccountsController do
  render_views

  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:followee_bob) { Fabricate(:account, username: 'bob') }
  let(:followee_chris) { Fabricate(:account, username: 'chris') }

  describe 'GET #index' do
    let!(:follow_of_bob) { alice.follow!(followee_bob) }
    let!(:follow_of_chris) { alice.follow!(followee_chris) }

    context 'when format is html' do
      subject(:response) { get :index, params: { account_username: alice.username, format: :html } }

      context 'when account is permanently suspended' do
        before do
          alice.suspend!
          alice.deletion_request.destroy
        end

        it 'returns http gone' do
          expect(response).to have_http_status(410)
        end
      end

      context 'when account is temporarily suspended' do
        before do
          alice.suspend!
        end

        it 'returns http forbidden' do
          expect(response).to have_http_status(403)
        end
      end
    end

    context 'when format is json' do
      let(:response) { get :index, params: { account_username: alice.username, page: page, format: :json } }

      context 'with page' do
        let(:page) { 1 }

        it 'returns followers' do
          expect(response).to have_http_status(200)
          expect(response.parsed_body)
            .to include(
              orderedItems: contain_exactly(
                include(follow_of_bob.target_account.username),
                include(follow_of_chris.target_account.username)
              ),
              totalItems: eq(2),
              partOf: be_present
            )
        end

        context 'when account is permanently suspended' do
          before do
            alice.suspend!
            alice.deletion_request.destroy
          end

          it 'returns http gone' do
            expect(response).to have_http_status(410)
          end
        end

        context 'when account is temporarily suspended' do
          before do
            alice.suspend!
          end

          it 'returns http forbidden' do
            expect(response).to have_http_status(403)
          end
        end
      end

      context 'without page' do
        let(:page) { nil }

        it 'returns followers' do
          expect(response).to have_http_status(200)
          expect(response.parsed_body)
            .to include(
              totalItems: eq(2)
            )
            .and not_include(:partOf)
        end

        context 'when account hides their network' do
          before do
            alice.update(hide_collections: true)
          end

          it 'returns followers count but not any items' do
            expect(response.parsed_body)
              .to include(
                totalItems: eq(2)
              )
              .and not_include(
                :items,
                :orderedItems,
                :first,
                :last
              )
          end
        end

        context 'when account is permanently suspended' do
          before do
            alice.suspend!
            alice.deletion_request.destroy
          end

          it 'returns http gone' do
            expect(response).to have_http_status(410)
          end
        end

        context 'when account is temporarily suspended' do
          before do
            alice.suspend!
          end

          it 'returns http forbidden' do
            expect(response).to have_http_status(403)
          end
        end
      end
    end
  end
end
