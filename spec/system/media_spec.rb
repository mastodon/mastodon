# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media' do
  describe 'Player page' do
    let(:status) { Fabricate :status }

    before { status.media_attachments << media }

    context 'when signed in' do
      before { sign_in Fabricate(:user) }

      context 'when media type is video' do
        let(:media) { Fabricate :media_attachment, type: :video }

        it 'visits the player page and renders media' do
          visit medium_player_path(media)

          expect(page)
            .to have_css('body', class: 'player')
            .and have_css('div[data-component="Video"] video[controls="controls"] source')
        end
      end

      context 'when media type is gifv' do
        let(:media) { Fabricate :media_attachment, type: :gifv }

        it 'visits the player page and renders media' do
          visit medium_player_path(media)

          expect(page)
            .to have_css('body', class: 'player')
            .and have_css('div[data-component="MediaGallery"] video[loop="loop"] source')
        end
      end

      context 'when media type is audio' do
        let(:media) { Fabricate :media_attachment, type: :audio }

        it 'visits the player page and renders media' do
          visit medium_player_path(media)

          expect(page)
            .to have_css('body', class: 'player')
            .and have_css('div[data-component="Audio"] audio source')
        end
      end
    end
  end
end
