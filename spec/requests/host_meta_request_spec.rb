# frozen_string_literal: true

require 'rails_helper'

describe 'The host_meta route' do
  describe 'requested without accepts headers' do
    it 'returns an xml response' do
      get host_meta_url

      expect(response).to have_http_status(200)
      expect(response.media_type).to eq 'application/xrd+xml'
    end
  end
end
