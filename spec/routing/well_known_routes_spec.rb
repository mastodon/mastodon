# frozen_string_literal: true

require 'rails_helper'

describe 'Well Known routes' do
  describe 'the host-meta route' do
    it 'routes to correct place with xml format' do
      expect(get('/.well-known/host-meta'))
        .to route_to('well_known/host_meta#show', format: 'xml')
    end
  end

  describe 'the webfinger route' do
    it 'routes to correct place with json format' do
      expect(get('/.well-known/webfinger'))
        .to route_to('well_known/webfinger#show')
    end
  end

  describe 'the nodeinfo routes' do
    it 'routes to discovery (index) route' do
      expect(get('/.well-known/nodeinfo'))
        .to route_to('well_known/node_info#index', format: 'json')
    end

    it 'routes to the show route' do
      expect(get('/nodeinfo/2.0'))
        .to route_to('well_known/node_info#show')
    end
  end
end
