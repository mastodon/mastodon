# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Instances::ExtendedDescriptionsController do
  render_views

  describe 'GET #show' do
    it 'returns http success' do
      get :show

      expect(response).to have_http_status(200)
    end
  end
end
