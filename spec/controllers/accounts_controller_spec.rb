require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  render_views

  let(:alice) { Fabricate(:account, username: 'alice', user: Fabricate(:user)) }
  let(:eve) { Fabricate(:user) }

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
      alice.block!(eve.account)
      status3.media_attachments.create!(account: alice, file: fixture_file_upload('files/attachment.jpg', 'image/jpeg'))
    end

    shared_examples 'responses' do
      before do
        sign_in(current_user) if defined? current_user
        get :show, params: {
          username: alice.username,
          max_id: (max_id if defined? max_id),
          since_id: (since_id if defined? since_id),
          current_user: (current_user if defined? current_user),
        }, format: format
      end

      it 'assigns @account' do
        expect(assigns(:account)).to eq alice
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'returns correct format' do
        expect(response.content_type).to eq content_type
      end
    end

    context 'activitystreams2' do
      let(:format) { 'json' }
      let(:content_type) { 'application/activity+json' }

      include_examples 'responses'
    end

    context 'html' do
      let(:format) { nil }
      let(:content_type) { 'text/html' }

      shared_examples 'responsed statuses' do
        it 'assigns @pinned_statuses' do
          pinned_statuses = assigns(:pinned_statuses).to_a
          expect(pinned_statuses.size).to eq expected_pinned_statuses.size
          pinned_statuses.each.zip(expected_pinned_statuses.each) do |pinned_status, expected_pinned_status|
            expect(pinned_status).to eq expected_pinned_status
          end
        end

        it 'assigns @statuses' do
          statuses = assigns(:statuses).to_a
          expect(statuses.size).to eq expected_statuses.size
          statuses.each.zip(expected_statuses.each) do |status, expected_status|
            expect(status).to eq expected_status
          end
        end
      end

      include_examples 'responses'

      context 'with anonymous visitor' do
        context 'without since_id nor max_id' do
          let(:expected_statuses) { [status7, status6, status5, status4, status3, status2, status1] }
          let(:expected_pinned_statuses) { [status7, status5, status6] }

          include_examples 'responsed statuses'
        end

        context 'with since_id nor max_id' do
          let(:max_id) { status4.id }
          let(:since_id) { status1.id }
          let(:expected_statuses) { [status3, status2] }
          let(:expected_pinned_statuses) { [] }

          include_examples 'responsed statuses'
        end
      end

      context 'with blocked visitor' do
        let(:current_user) { eve }

        context 'without since_id nor max_id' do
          let(:expected_statuses) { [] }
          let(:expected_pinned_statuses) { [] }

          include_examples 'responsed statuses'
        end
      end
    end
  end
end
