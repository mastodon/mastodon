# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Featured Tags' do
  describe 'POST /settings/featured_tags' do
    context 'when signed in' do
      before { sign_in Fabricate(:user) }

      it 'gracefully handles invalid nested params' do
        post settings_featured_tags_path(featured_tag: 'invalid')

        expect(response)
          .to have_http_status(400)
      end
    end

    context 'when not signed in' do
      subject { post settings_featured_tags_path }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end
end
