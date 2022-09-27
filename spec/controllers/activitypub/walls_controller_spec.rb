require 'rails_helper'

RSpec.describe ActivityPub::WallsController, type: :controller do
  let!(:group)           { Fabricate(:group) }
  let!(:unrelated_group) { Fabricate(:group) }
  let!(:account)         { Fabricate(:account) }
  let!(:remote_account)  { Fabricate(:account, domain: 'foobar.com') }
  let!(:membership1)     { Fabricate(:group_membership, group: group, account: account) }
  let!(:membership2)     { Fabricate(:group_membership, group: group, account: remote_account) }
  let!(:membership3)     { Fabricate(:group_membership, group: unrelated_group, account: account) }

  let!(:implicitly_approved_status) { Fabricate(:status, account: account, visibility: :group, group: group) }
  let!(:pending_status)             { Fabricate(:status, account: account, visibility: :group, group: group, approval_status: :pending) }
  let!(:revoked_status)             { Fabricate(:status, account: account, visibility: :group, group: group, approval_status: :revoked) }
  let!(:approved_status)            { Fabricate(:status, account: account, visibility: :group, group: group, approval_status: :approved) }
  let!(:remote_status)              { Fabricate(:status, account: remote_account, visibility: :group, group: group, uri: 'https://foobar.com/statuses/1234') }
  let!(:unrelated_status)           { Fabricate(:status, account: account, visibility: :group, group: unrelated_group) }
  let(:expected_statuses)           { [implicitly_approved_status, approved_status, remote_status] }

  shared_examples 'cacheable response' do
    it 'does not set cookies' do
      expect(response.cookies).to be_empty
      expect(response.headers['Set-Cookies']).to be nil
    end

    it 'does not set sessions' do
      response
      expect(session).to be_empty
    end

    it 'returns public Cache-Control header' do
      expect(response.headers['Cache-Control']).to include 'public'
    end
  end

  shared_examples 'page response' do
    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns application/activity+json' do
      expect(response.media_type).to eq 'application/activity+json'
    end

    it 'returns orderedItems with the expected number of posts' do
      expect(body[:orderedItems]).to be_an Array
      expect(body[:orderedItems].size).to eq 3
    end

    it 'returns the expected posts' do
      expect(body[:orderedItems].map { |item| item.is_a?(Hash) ? item[:id] : item }).to match_array(expected_statuses.map { |status| ActivityPub::TagManager.instance.uri_for(status) })
    end

    it 'returns only inline items that are local group statuses' do
      inlined_posts = body[:orderedItems].select { |x| x.is_a?(Hash) }
      wall_uri = ActivityPub::TagManager.instance.wall_uri_for(group)
      group_uri = ActivityPub::TagManager.instance.uri_for(group)
      expect(inlined_posts.map { |item| ActivityPub::TagManager.instance.local_uri?(item[:id]) }).to all(be true)
      expect(inlined_posts.map { |item| item[:target] }).to all (include({ id: wall_uri, attributedTo: group_uri }))
    end

    it 'uses ids for remote posts' do
      remote_posts = body[:orderedItems].select { |x| !x.is_a?(Hash) }
      expect(remote_posts.all? { |item| item.is_a?(String) && !ActivityPub::TagManager.instance.local_uri?(item) }).to be true
    end
  end

  before do
    allow(controller).to receive(:signed_request_actor).and_return(remote_querier)
  end

  describe 'GET #show' do
    context 'without signature' do
      let(:remote_querier) { nil }

      subject(:response) { get :show, params: { group_id: group.id, page: page } }
      subject(:body) { body_as_json }

      context 'with page not requested' do
        let(:page) { nil }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it 'returns totalItems' do
          expect(body[:totalItems]).to eq 5 # (includes non-approved posts)
        end

        it_behaves_like 'cacheable response'

        it 'does not have a Vary header' do
          expect(response.headers['Vary']).to be_nil
        end

        context 'when group is permanently suspended' do
          before do
            group.suspend!
            group.deletion_request.destroy
          end

          it 'returns http gone' do
            expect(response).to have_http_status(410)
          end
        end

        context 'when group is temporarily suspended' do
          before do
            group.suspend!
          end

          it 'returns http forbidden' do
            expect(response).to have_http_status(403)
          end
        end
      end

      context 'with page requested' do
        let(:page) { 'true' }

        it_behaves_like 'page response'

        it_behaves_like 'cacheable response'

        it 'returns Vary header with Signature' do
          expect(response.headers['Vary']).to include 'Signature'
        end

        context 'when group is permanently suspended' do
          before do
            group.suspend!
            group.deletion_request.destroy
          end

          it 'returns http gone' do
            expect(response).to have_http_status(410)
          end
        end

        context 'when group is temporarily suspended' do
          before do
            group.suspend!
          end

          it 'returns http forbidden' do
            expect(response).to have_http_status(403)
          end
        end
      end
    end

    context 'with signature' do
      let(:remote_querier) { Fabricate(:account, domain: 'example.com') }

      context 'with page requested' do
        let(:page) { 'true' }

        before do
          get :show, params: { group_id: group.id, page: page }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it 'returns orderedItems with group visibility statuses' do
          json = body_as_json
          expect(json[:orderedItems]).to be_an Array
          expect(json[:orderedItems].size).to eq 3
          # TODO: expect(json[:orderedItems].all? { |item| item[:to].include?(ActivityPub::TagManager::COLLECTIONS[:public]) || item[:cc].include?(ActivityPub::TagManager::COLLECTIONS[:public]) }).to be true
        end

        it 'returns private Cache-Control header' do
          expect(response.headers['Cache-Control']).to eq 'max-age=60, private'
        end
      end
    end
  end
end
