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

      expect(helper.site_title).to eq ''
    end
  end

  describe 'site_hostname' do
    around(:each) do |example|
      before = Rails.configuration.x.local_domain
      example.run
      Rails.configuration.x.local_domain = before
    end

    it 'returns the local domain value' do
      Rails.configuration.x.local_domain = 'example.com'

      expect(helper.site_hostname).to eq 'example.com'
    end
  end
end
