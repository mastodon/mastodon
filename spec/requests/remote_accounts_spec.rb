# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Remote Accounts' do
  describe 'GET /@:username_with_domain' do
    before { sign_in Fabricate(:user) }

    context 'when account is missing' do
      it 'returns http not found while also rendering the page' do
        get '/@username@host.example'

        expect(response)
          .to have_http_status(404)
        expect(response.body)
          .to have_css('noscript', text: /Mastodon/)
          .and have_css('body', class: 'app-body')
      end
    end
  end
end
