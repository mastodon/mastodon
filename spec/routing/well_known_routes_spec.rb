# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Well Known routes' do
  describe 'the host-meta route' do
    it 'routes to correct place' do
      expect(get('/.well-known/host-meta'))
        .to route_to('well_known/host_meta#show')
    end

    it 'routes to correct place with json format' do
      expect(get('/.well-known/host-meta.json'))
        .to route_to('well_known/host_meta#show', format: 'json')
    end
  end

  describe 'the webfinger route' do
    it 'routes to correct place with json format' do
      expect(get('/.well-known/webfinger'))
        .to route_to('well_known/webfinger#show')
    end
  end
end
