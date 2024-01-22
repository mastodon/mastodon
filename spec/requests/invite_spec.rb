# frozen_string_literal: true

require 'rails_helper'

describe 'invites' do
  let(:invite) { Fabricate(:invite) }

  context 'when requesting a JSON document' do
    it 'returns a JSON document with expected attributes' do
      get "/invite/#{invite.code}", headers: { 'Accept' => 'application/activity+json' }

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/json'

      expect(body_as_json[:invite_code]).to eq invite.code
    end
  end

  context 'when not requesting a JSON document' do
    it 'returns an HTML page' do
      get "/invite/#{invite.code}"

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'text/html'
    end
  end
end
