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
      let(:page_json) { body_as_json[:first] }

      it_behaves_like 'cacheable response'

      it 'returns http success and correct media type' do
        expect(response).to have_http_status(200)
        expect(response.media_type).to eq 'application/activity+json'
      end

      context 'without only_other_accounts' do
        it "returns items with thread author's replies" do
          expect(page_json).to be_a Hash
          expect(page_json[:items]).to be_an Array
          expect(page_json[:items].size).to eq 1
          expect(page_json[:items].all? { |item| targets_public_collection?(item) }).to be true
        end

        context 'when there are few self-replies' do
          it 'points next to replies from other people' do
            expect(page_json).to be_a Hash
            expect(parsed_uri_query_values(page_json[:next])).to include('only_other_accounts=true', 'page=true')
          end
        end

        context 'when there are many self-replies' do
          before do
            10.times { Fabricate(:status, account: status.account, thread: status, visibility: :public) }
          end

          it 'points next to other self-replies' do
            expect(page_json).to be_a Hash
            expect(parsed_uri_query_values(page_json[:next])).to include('only_other_accounts=false', 'page=true')
          end
        end
      end

      context 'with only_other_accounts' do
        let(:only_other_accounts) { 'true' }

        it 'returns items with other public or unlisted replies' do
          expect(page_json).to be_a Hash
          expect(page_json[:items]).to be_an Array
          expect(page_json[:items].size).to eq 3
        end

        it 'only inlines items that are local and public or unlisted replies' do
          inlined_replies = page_json[:items].select { |x| x.is_a?(Hash) }
          expect(inlined_replies.all? { |item| targets_public_collection?(item) }).to be true
          expect(inlined_replies.all? { |item| ActivityPub::TagManager.instance.local_uri?(item[:id]) }).to be true
        end

        it 'uses ids for remote toots' do
          remote_replies = page_json[:items].reject { |x| x.is_a?(Hash) }
          expect(remote_replies.all? { |item| item.is_a?(String) && !ActivityPub::TagManager.instance.local_uri?(item) }).to be true
        end

        context 'when there are few replies' do
          it 'does not have a next page' do
            expect(page_json).to be_a Hash
            expect(page_json[:next]).to be_nil
          end
        end

        context 'when there are many replies' do
          before do
            10.times { Fabricate(:status, thread: status, visibility: :public) }
          end

          it 'points next to other replies' do
            expect(page_json).to be_a Hash
            expect(parsed_uri_query_values(page_json[:next])).to include('only_other_accounts=true', 'page=true')
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
