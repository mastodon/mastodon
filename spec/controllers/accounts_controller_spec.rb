require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  render_views

  let(:alice)  { Fabricate(:account, username: 'alice') }

  describe 'GET #show' do
    let!(:status1) { Status.create!(account: alice, text: 'Hello world') }
    let!(:status2) { Status.create!(account: alice, text: 'Boop', thread: status1) }
    let!(:status3) { Status.create!(account: alice, text: 'Picture!') }
    let!(:status4) { Status.create!(account: alice, text: 'Mentioning @alice') }
    let!(:status5) { Status.create!(account: alice, text: 'Kitsune') }
    let!(:status6) { Status.create!(account: alice, text: 'Neko') }
    let!(:status7) { Status.create!(account: alice, text: 'Tanuki') }

    let!(:status_pin1) { StatusPin.create!(account: alice, status: status5, created_at: 5.days.ago) }
    let!(:status_pin2) { StatusPin.create!(account: alice, status: status6, created_at: 2.years.ago) }
    let!(:status_pin3) { StatusPin.create!(account: alice, status: status7, created_at: 10.minutes.ago) }

    before do
      status3.media_attachments.create!(account: alice, file: fixture_file_upload('files/attachment.jpg', 'image/jpeg'))
    end

    context 'atom' do
      before do
        get :show, params: { username: alice.username, max_id: status4.stream_entry.id, since_id: status1.stream_entry.id }, format: 'atom'
      end

      it 'assigns @account' do
        expect(assigns(:account)).to eq alice
      end

      it 'assigns @entries' do
        entries = assigns(:entries).to_a
        expect(entries.size).to eq 2
        expect(entries[0].status).to eq status3
        expect(entries[1].status).to eq status2
      end

      it 'returns http success with Atom' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'activitystreams2' do
      before do
        get :show, params: { username: alice.username }, format: 'json'
      end

      it 'assigns @account' do
        expect(assigns(:account)).to eq alice
      end

      it 'returns http success with Activity Streams 2.0' do
        expect(response).to have_http_status(:success)
      end

      it 'returns application/activity+json' do
        expect(response.content_type).to eq 'application/activity+json'
      end
    end

    context 'html without since_id nor max_id' do
      before do
        get :show, params: { username: alice.username }
      end

      it 'assigns @account' do
        expect(assigns(:account)).to eq alice
      end

      it 'assigns @pinned_statuses' do
        pinned_statuses = assigns(:pinned_statuses).to_a
        expect(pinned_statuses.size).to eq 3
        expect(pinned_statuses[0]).to eq status7
        expect(pinned_statuses[1]).to eq status5
        expect(pinned_statuses[2]).to eq status6
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'html with since_id and max_id' do
      before do
        get :show, params: { username: alice.username, max_id: status4.id, since_id: status1.id }
      end

      it 'assigns @account' do
        expect(assigns(:account)).to eq alice
      end

      it 'assigns @statuses' do
        statuses = assigns(:statuses).to_a
        expect(statuses.size).to eq 2
        expect(statuses[0]).to eq status3
        expect(statuses[1]).to eq status2
      end

      it 'assigns an empty array to @pinned_statuses' do
        pinned_statuses = assigns(:pinned_statuses).to_a
        expect(pinned_statuses.size).to eq 0
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
