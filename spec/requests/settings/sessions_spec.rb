# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Sessions' do
  let(:user) { Fabricate(:user) }

  before { sign_in(user) }

  describe 'DELETE /settings/sessions/:id' do
    context 'when session activation does not exist' do
      it 'returns not found' do
        delete settings_session_path(123_456_789)

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
