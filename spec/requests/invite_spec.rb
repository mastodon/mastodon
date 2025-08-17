# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'invites' do
  let(:invite) { Fabricate(:invite) }

  context 'when requesting a JSON document' do
    subject { get "/invite/#{invite.code}", headers: { 'Accept' => 'application/activity+json' } }

    context 'when invite is valid' do
      it 'returns a JSON document with expected attributes' do
        subject

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq 'application/json'
        expect(response.parsed_body)
          .to include(invite_code: invite.code)
      end
    end

    context 'when invite is expired' do
      before { invite.update(expires_at: 3.days.ago) }

      it 'returns a JSON document with error details' do
        subject

        expect(response)
          .to have_http_status(401)
        expect(response.media_type)
          .to eq 'application/json'
        expect(response.parsed_body)
          .to include(error: I18n.t('invites.invalid'))
      end
    end

    context 'when user IP is blocked' do
      before { Fabricate :ip_block, severity: :sign_up_block, ip: '127.0.0.1' }

      it 'returns a JSON document with error details' do
        subject

        expect(response)
          .to have_http_status(403)
        expect(response.media_type)
          .to eq 'application/json'
        expect(response.parsed_body)
          .to include(error: /This action is not allowed/)
      end
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
