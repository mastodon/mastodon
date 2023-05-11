# frozen_string_literal: true

require 'rails_helper'

describe FlashesHelper do
  describe 'user_facing_flashes' do
    it 'returns user facing flashes' do
      flash[:alert] = 'an alert'
      flash[:error] = 'an error'
      flash[:notice] = 'a notice'
      flash[:success] = 'a success'
      flash[:not_user_facing] = 'a not user facing flash'
      expect(helper.user_facing_flashes).to eq 'alert' => 'an alert',
                                               'error' => 'an error',
                                               'notice' => 'a notice',
                                               'success' => 'a success'
    end
  end
end
