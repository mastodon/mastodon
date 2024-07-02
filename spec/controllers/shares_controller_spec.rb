# frozen_string_literal: true

require 'rails_helper'

describe SharesController do
  render_views

  let(:user) { Fabricate(:user) }

  before { sign_in user }

  describe 'GET #show' do
    before { get :show, params: { title: 'test title', text: 'test text', url: 'url1 url2' } }

    it 'returns http success' do
      expect(response).to have_http_status 200
      expect(body_class_values)
        .to include('modal-layout', 'compose-standalone')
    end

    def body_class_values
      Nokogiri::Slop(response.body).css('body').first.classes
    end
  end
end
