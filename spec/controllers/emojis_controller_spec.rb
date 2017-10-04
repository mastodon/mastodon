# frozen_string_literal: true

require 'rails_helper'

describe EmojisController, type: :controller do
  describe 'GET #show' do
    let(:emoji) { Fabricate(:custom_emoji_icon, uri: nil) }

    it 'renders Atom' do
      get :show, format: 'atom', params: { id: emoji }
      expect(response).to have_http_status :success
    end

    it 'renders JSON' do
      get :show, format: 'json', params: { id: emoji }
      expect(response).to have_http_status :success
    end
  end
end
