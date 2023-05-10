# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteUpload do
  describe '#cache_key' do
    let(:site_upload) { SiteUpload.new(var: 'var') }

    it 'returns cache_key' do
      expect(site_upload.cache_key).to eq 'site_uploads/var'
    end
  end
end
