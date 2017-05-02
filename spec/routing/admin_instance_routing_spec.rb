# frozen_string_literal: true

require 'rails_helper'

describe 'the admin/instances show route' do
  it 'recognizes an :id value with a dot' do
    expect(get('/admin/instances/example.com')).
      to route_to('admin/instances#show', id: 'example.com')
  end
end
