# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Settings::FlavoursController, type: :controller do
  let(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'PUT #update' do
    describe 'without a user[setting_skin] parameter' do
      it 'sets the selected flavour' do
        put :update, params: { flavour: 'schnozzberry' }

        user.reload

        expect(user.setting_flavour).to eq 'schnozzberry'
      end
    end

    describe 'with a user[setting_skin] parameter' do
      before do
        put :update, params: { flavour: 'schnozzberry', user: { setting_skin: 'wallpaper' } }

        user.reload
      end

      it 'sets the selected flavour' do
        expect(user.setting_flavour).to eq 'schnozzberry'
      end

      it 'sets the selected skin' do
        expect(user.setting_skin).to eq 'wallpaper'
      end
    end
  end
end
