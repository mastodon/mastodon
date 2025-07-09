# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Configuration for email', type: :feature do
  context 'with special characters in SMTP_PASSWORD env variable' do
    let(:password) { ']]123456789[["!:@<>/\\=' }

    around do |example|
      ClimateControl.modify SMTP_PASSWORD: password do
        example.run
      end
    end

    it 'parses value correctly' do
      expect(Rails.application.config_for(:email, env: :production))
        .to include(
          smtp_settings: include(password: password)
        )
    end
  end
end
