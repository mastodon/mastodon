# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstanceHelper do
  describe 'site_title' do
    it 'Uses the Setting.site_title value when it exists' do
      Setting.site_title = 'New site title'

      expect(helper.site_title).to eq 'New site title'
    end
  end

  describe 'site_hostname' do
    around do |example|
      before = Rails.configuration.x.local_domain
      example.run
      Rails.configuration.x.local_domain = before
    end

    it 'returns the local domain value' do
      Rails.configuration.x.local_domain = 'example.com'

      expect(helper.site_hostname).to eq 'example.com'
    end
  end

  describe 'favicon' do
    context 'when an icon exists' do
      let!(:favicon) { Fabricate(:site_upload, var: 'favicon') }
      let!(:app_icon) { Fabricate(:site_upload, var: 'app_icon') }

      it 'returns the URL of the icon' do
        expect(helper.favicon_path).to eq(favicon.file.url('48'))
        expect(helper.app_icon_path).to eq(app_icon.file.url('48'))
      end

      it 'returns the URL of the icon with size parameter' do
        expect(helper.favicon_path(16)).to eq(favicon.file.url('16'))
        expect(helper.app_icon_path(16)).to eq(app_icon.file.url('16'))
      end
    end

    context 'when an icon does not exist' do
      it 'returns nil' do
        expect(helper.favicon_path).to be_nil
        expect(helper.app_icon_path).to be_nil
      end

      it 'returns nil with size parameter' do
        expect(helper.favicon_path(16)).to be_nil
        expect(helper.app_icon_path(16)).to be_nil
      end
    end
  end
end
