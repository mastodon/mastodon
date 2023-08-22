# frozen_string_literal: true

require 'rails_helper'

describe 'The `/health` system check URL' do
  it 'returns http success' do
    get '/health'

    expect(response).to have_http_status(200)
  end
end
