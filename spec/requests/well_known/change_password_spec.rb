# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The /.well-known/change-password request' do
  it 'redirects to the change password page' do
    get '/.well-known/change-password'

    expect(response).to redirect_to '/auth/edit'
  end
end
