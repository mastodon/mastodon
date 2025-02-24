# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::RepliesController do
  let(:status) { Fabricate(:status, visibility: parent_visibility) }
  let(:remote_account)  { Fabricate(:account, domain: 'foobar.com') }
  let(:remote_reply_id) { 'https://foobar.com/statuses/1234' }
  let(:remote_querier) { nil }

  shared_examples 'common behavior' do
    context 'when status is private' do
      let(:parent_visibility) { :private }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when status is direct' do
      let(:parent_visibility) { :direct }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  shared_examples 'disallowed access' do
    context 'when status is public' do
      let(:parent_visibility) { :public }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end

    it_behaves_like 'common behavior'
  end

  shared_examples 'allowed access' do
    context 'when account is permanently suspended' do
      let(:parent_visibility) { :public }

      before do
        status.account.suspend!
        status.account.deletion_request.destroy
      end

      it 'returns http gone' do
        expect(response).to have_http_status(410)
      end
    end

    context 'when account is temporarily suspended' do
      let(:parent_visibility) { :public }

      before do
        status.account.suspend!
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when status is public' do
      let(:parent_visibility) { :public }

      it 'returns http success and correct media type' do
        expect(response)
          .to have_http_status(200)
          .and have_cacheable_headers

        expect(response.media_type).to eq 'application/activity+json'
      end

      context 'without only_other_accounts' do
        it "returns items with thread author's replies" do
          expect(response.parsed_body)
            .to include(
              first: be_a(Hash).and(
                include(
                  items: be_an(Array)
                  .and(have_attributes(size: 1))
                  .and(all(satisfy { |item| targets_public_collection?(item) }))
                )
              )
            )
        end

        context 'when there are few self-replies' do
          it 'points next to replies from other people' do
            expect(response.parsed_body)
              .to include(
                first: be_a(Hash).and(
                  include(
                    next: satisfy { |value| (parsed_uri_query_values(value) & %w(only_other_accounts=true page=true)).any? }
                  )
                )
              )
          end
        end

        context 'when there are many self-replies' do
          before do
            10.times { Fabricate(:status, account: status.account, thread: status, visibility: :public) }
          end

          it 'points next to other self-replies' do
            expect(response.parsed_body)
              .to include(
                first: be_a(Hash).and(
                  include(
                    next: satisfy { |value| (parsed_uri_query_values(value) & %w(only_other_accounts=false page=true)).any? }
                  )
                )
              )
          end
        end
      end

      context 'with only_other_accounts' do
        let(:only_other_accounts) { 'true' }

        it 'returns items with other public or unlisted replies' do
          expect(response.parsed_body)
            .to include(
              first: be_a(Hash).and(
                include(items: be_an(Array).and(have_attributes(size: 3)))
              )
            )
        end

        it 'only inlines items that are local and public or unlisted replies' do
          expect(inlined_replies)
            .to all(satisfy { |item| targets_public_collection?(item) })
            .and all(satisfy { |item| ActivityPub::TagManager.instance.local_uri?(item[:id]) })
        end

        it 'uses ids for remote toots' do
          expect(remote_replies)
            .to all(satisfy { |item| item.is_a?(String) && !ActivityPub::TagManager.instance.local_uri?(item) })
        end

        context 'when there are few replies' do
          it 'does not have a next page' do
            expect(response.parsed_body)
              .to include(
                first: be_a(Hash).and(not_include(next: be_present))
              )
          end
        end

        context 'when there are many replies' do
          before do
            10.times { Fabricate(:status, thread: status, visibility: :public) }
          end

          it 'points next to other replies' do
            expect(response.parsed_body)
              .to include(
                first: be_a(Hash).and(
                  include(
                    next: satisfy { |value| (parsed_uri_query_values(value) & %w(only_other_accounts=true page=true)).any? }
                  )
                )
              )
          end
        end
      end
    end

    it_behaves_like 'common behavior'
  end

  before do
    stub_const 'ActivityPub::RepliesController::DESCENDANTS_LIMIT', 5
    allow(controller).to receive(:signed_request_actor).and_return(remote_querier)

    Fabricate(:status, thread: status, visibility: :public)
    Fabricate(:status, thread: status, visibility: :public)
    Fabricate(:status, thread: status, visibility: :private)
    Fabricate(:status, account: status.account, thread: status, visibility: :public)
    Fabricate(:status, account: status.account, thread: status, visibility: :private)

    Fabricate(:status, account: remote_account, thread: status, visibility: :public, uri: remote_reply_id)
  end

  describe 'GET #index' do
    subject(:response) { get :index, params: { account_username: status.account.username, status_id: status.id, only_other_accounts: only_other_accounts } }

    let(:only_other_accounts) { nil }

    context 'with no signature' do
      it_behaves_like 'allowed access'
    end

    context 'with signature' do
      let(:remote_querier) { Fabricate(:account, domain: 'example.com') }

      it_behaves_like 'allowed access'

      context 'when signed request account is blocked' do
        before do
          status.account.block!(remote_querier)
        end

        it_behaves_like 'disallowed access'
      end

      context 'when signed request account is domain blocked' do
        before do
          status.account.block_domain!(remote_querier.domain)
        end

        it_behaves_like 'disallowed access'
      end
    end
  end

  private

  def inlined_replies
    response
      .parsed_body[:first][:items]
      .select { |x| x.is_a?(Hash) }
  end

  def remote_replies
    response
      .parsed_body[:first][:items]
      .reject { |x| x.is_a?(Hash) }
  end

  def parsed_uri_query_values(uri)
    Addressable::URI
      .parse(uri)
      .query
      .split('&')
  end

  def ap_public_collection
    ActivityPub::TagManager::COLLECTIONS[:public]
  end

  def targets_public_collection?(item)
    item[:to].include?(ap_public_collection) || item[:cc].include?(ap_public_collection)
  end
end
