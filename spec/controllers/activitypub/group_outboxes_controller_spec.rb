require 'rails_helper'

RSpec.describe ActivityPub::GroupOutboxesController, type: :controller do
  let!(:group) { Fabricate(:group) }

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

  before do
    account = Fabricate(:group_membership, group: group).account
    Fabricate(:status, account: account, visibility: :group, group: group)
    Fabricate(:status, account: account, visibility: :group, group: group, approval_status: :pending)
    Fabricate(:status, account: account, visibility: :group, group: group, approval_status: :revoked)
    Fabricate(:status, account: account, visibility: :group, group: group, approval_status: :approved)
  end

  describe 'GET #show' do
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
        expect(body[:totalItems]).to eq 0
      end

      it_behaves_like 'cacheable response'

      it 'does not have a Vary header' do
        expect(response.headers['Vary']).to be_nil
      end
    end
  end
end
