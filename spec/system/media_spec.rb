# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media' do
  describe 'Player page' do
    context 'when signed in' do
      before { sign_in Fabricate(:user) }

      it 'visits the media player page and renders the media' do
        status = Fabricate :status
        media = Fabricate :media_attachment, type: :video
        status.media_attachments << media

        visit medium_player_path(media)

        expect(page)
          .to have_css('body', class: 'player')
          .and have_css('div[data-component="Video"]')
      end
    end
  end
end
