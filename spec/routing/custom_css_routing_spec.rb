# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom CSS routes' do
  describe 'the legacy route' do
    it 'routes to correct place' do
      expect(get('/custom.css'))
        .to route_to('custom_css#show')
    end
  end

  describe 'the custom digest route' do
    it 'routes to correct place' do
      expect(get('/css/custom-1a2s3d4f.css'))
        .to route_to('custom_css#show', id: 'custom-1a2s3d4f', format: 'css')
    end
  end
end
