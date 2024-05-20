# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagsController do
  render_views

  describe 'GET #show' do
    let(:format) { 'html' }
    let(:tag) { Fabricate(:tag, name: 'test') }
    let(:tag_name) { tag&.name }

    before do
      get :show, params: { id: tag_name, format: format }
    end

    context 'when tag exists' do
      context 'when requested as HTML' do
        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'
      end

      context 'when requested as JSON' do
        let(:format) { 'json' }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'
      end
    end

    context 'when tag does not exist' do
      let(:tag_name) { 'hoge' }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
