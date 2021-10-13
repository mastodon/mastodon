# frozen_string_literal: true

require 'rails_helper'

describe MediaController do
  render_views

  describe '#show' do
    it 'raises when shortcode cant be found' do
      get :show, params: { id: 'missing' }

      expect(response).to have_http_status(404)
    end

    context 'when the media attachment has a shortcode' do
      it 'redirects to the file url when attached to a status' do
        status = Fabricate(:status)
        media_attachment = Fabricate(:media_attachment, status: status, shortcode: 'OI6IgDzG-nYTqvDQ994')
        get :show, params: { id: media_attachment.to_param }

        expect(response).to redirect_to(media_attachment.file.url(:original))
      end

      it 'responds with missing when there is not an attached status' do
        media_attachment = Fabricate(:media_attachment, status: nil, shortcode: 'OI6IgDzG-nYTqvDQ994')
        get :show, params: { id: media_attachment.to_param }

        expect(response).to have_http_status(404)
      end

      it 'raises when not permitted to view' do
        status = Fabricate(:status, visibility: :direct)
        media_attachment = Fabricate(:media_attachment, status: status, shortcode: 'OI6IgDzG-nYTqvDQ994')
        get :show, params: { id: media_attachment.to_param }

        expect(response).to have_http_status(404)
      end
    end

    context 'when the media attachment has no shortcode' do
      it 'redirects to the file url when attached to a status' do
        status = Fabricate(:status)
        media_attachment = Fabricate(:media_attachment, status: status)
        get :show, params: { id: media_attachment.to_param }

        expect(response).to redirect_to(media_attachment.file.url(:original))
      end

      it 'responds with missing when there is not an attached status' do
        media_attachment = Fabricate(:media_attachment, status: nil)
        get :show, params: { id: media_attachment.to_param }

        expect(response).to have_http_status(404)
      end

      it 'raises when not permitted to view' do
        status = Fabricate(:status, visibility: :direct)
        media_attachment = Fabricate(:media_attachment, status: status)
        get :show, params: { id: media_attachment.to_param }

        expect(response).to have_http_status(404)
      end
    end
  end
end
