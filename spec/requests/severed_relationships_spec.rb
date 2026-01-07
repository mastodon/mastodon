# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Severed Relationships' do
  let(:account_rs_event) { Fabricate(:account_relationship_severance_event) }
  let(:user) { account_rs_event.account.user }

  before { sign_in user }

  describe 'GET /severed_relationships/:id/following' do
    it 'returns a CSV file with correct data' do
      get following_severed_relationship_path(account_rs_event, format: :csv)

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('text/csv')
      expect(response.headers['Content-Disposition'])
        .to match(<<~FILENAME.squish)
          attachment; filename="following-example.com-#{Date.current}.csv"
        FILENAME
      expect(response.body)
        .to include('Account address')
    end

    context 'when the user is not the subject of the event' do
      let(:user) { Fabricate(:user) }

      it 'returns a 404' do
        get following_severed_relationship_path(account_rs_event, format: :csv)

        expect(response)
          .to have_http_status(404)
      end
    end
  end

  describe 'GET /severed_relationships/:id/followers' do
    it 'returns a CSV file with correct data' do
      get followers_severed_relationship_path(account_rs_event, format: :csv)

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('text/csv')
      expect(response.headers['Content-Disposition'])
        .to match(<<~FILENAME.squish)
          attachment; filename="followers-example.com-#{Date.current}.csv"
        FILENAME
      expect(response.body)
        .to include('Account address')
    end

    context 'when the user is not the subject of the event' do
      let(:user) { Fabricate(:user) }

      it 'returns a 404' do
        get followers_severed_relationship_path(account_rs_event, format: :csv)

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
