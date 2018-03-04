# frozen_string_literal: true

require 'rails_helper'

describe InstanceHelper do
  describe 'site_title' do
    around do |example|
      site_title = Setting.site_title
      example.run
      Setting.site_title = site_title
    end

    it 'Uses the Setting.site_title value when it exists' do
      Setting.site_title = 'New site title'

      expect(helper.site_title).to eq 'New site title'
    end

    it 'returns empty string when Setting.site_title is nil' do
      Setting.site_title = nil

      expect(helper.site_title).to eq 'cb6e6126.ngrok.io'
    end
  end

  describe 'site_hostname' do
    it 'uses Setting.site_hostname_or_domain value' do
      expect(helper.site_hostname).to eq 'cb6e6126.ngrok.io'
    end
  end
end
