require 'rails_helper'

RSpec.describe StreamEntriesController, type: :controller do
  render_views

  let(:alice)     { Fabricate(:account, username: 'alice', display_name: 'Alice') }
  let(:bob)       { Fabricate(:account, username: 'bob', display_name: 'Bob') }
  let(:status)    { Fabricate(:status, account: alice) }
  let(:reply)     { Fabricate(:status, account: bob, thread: status) }

  describe 'GET #show' do
    it 'returns http success with HTML' do
      get :show, params: { account_username: alice.username, id: status.stream_entry.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns http success with Atom' do
      get :show, params: { account_username: alice.username, id: status.stream_entry.id }, format: 'atom'
      expect(response).to have_http_status(:success)
    end

    it 'returns an h-entry with a p-author.h-card with a p-name and u-url' do
      get :show, params: { account_username: bob.username, id: reply.stream_entry.id }
      mf2 = Microformats2.parse(response.body)
      expect(mf2.entry.author.format.name.to_s).to eq bob.display_name
      expect(mf2.entry.author.format.url.to_s).not_to be_empty
    end

    it 'returns a reply h-entry with a u-url and p-in-reply-to with a u-url' do
      get :show, params: { account_username: bob.username, id: reply.stream_entry.id }
      mf2 = Microformats2.parse(response.body)
      expect(mf2.entry.in_reply_to.format.url.to_s).not_to be_empty
      expect(mf2.entry.url.to_s).not_to be_empty
    end

  end

  describe 'GET #embed' do
    it 'returns embedded view of status' do
      get :embed, params: { account_username: alice.username, id: status.stream_entry.id }

      expect(response).to have_http_status(:success)
      expect(response.headers['X-Frame-Options']).to eq 'ALLOWALL'
      expect(response).to render_template(layout: 'embedded')
    end
  end
end
