# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Registrations' do
  describe 'Signing up for a new account' do
    context 'when registrations are closed' do
      subject do
        get new_user_registration_path
        follow_redirect!
      end

      around do |example|
        original = Setting.registrations_mode
        Setting.registrations_mode = 'none'
        example.run
        Setting.registrations_mode = original
        Setting.closed_registrations_message = ''
      end

      context 'when there is a custom message' do
        before { Setting.closed_registrations_message = 'You shall not pass' }

        it 'includes the custom message' do
          subject

          expect(response.body)
            .to have_css('.flash-message', text: /shall not pass/i)
        end
      end

      context 'when there is not a custom message' do
        before { Setting.closed_registrations_message = '' }

        it 'includes the default message' do
          subject

          expect(response.body)
            .to have_css('.flash-message', text: /network policy/i)
        end
      end
    end
  end
end
