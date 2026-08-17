# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Wrapstodon' do
  let(:generated_annual_report) { AnnualReport.new(user.account, Time.current.year).generate }
  let(:user) { Fabricate :user }

  describe 'GET /@:account_username/wrapstodon/:year/:share_key' do
    context 'when share_key is invalid' do
      it 'returns not found' do
        get public_wrapstodon_path(account_username: user.account.username, year: generated_annual_report.year, share_key: 'sharks')

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
