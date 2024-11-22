# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlashesHelper do
  describe 'user_facing_flashes' do
    before do
      # rubocop:disable Rails/I18nLocaleTexts
      flash[:alert] = 'an alert'
      flash[:error] = 'an error'
      flash[:notice] = 'a notice'
      flash[:success] = 'a success'
      flash[:not_user_facing] = 'a not user facing flash'
      # rubocop:enable Rails/I18nLocaleTexts
    end

    it 'returns user facing flashes' do
      expect(helper.user_facing_flashes).to eq(
        'alert' => 'an alert',
        'error' => 'an error',
        'notice' => 'a notice',
        'success' => 'a success'
      )
    end
  end
end
