# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController do
  describe 'helper_method :single_user_mode?' do
    it 'returns false if it is in single_user_mode but there is no account' do
      allow(Rails.configuration.x).to receive(:single_user_mode).and_return(true)
      expect(controller.view_context.single_user_mode?).to eq false
    end

    it 'returns false if there is an account but it is not in single_user_mode' do
      allow(Rails.configuration.x).to receive(:single_user_mode).and_return(false)
      Fabricate(:account)
      expect(controller.view_context.single_user_mode?).to eq false
    end

    it 'returns true if it is in single_user_mode and there is an account' do
      allow(Rails.configuration.x).to receive(:single_user_mode).and_return(true)
      Fabricate(:account)
      expect(controller.view_context.single_user_mode?).to eq true
    end
  end
end
