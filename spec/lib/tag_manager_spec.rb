# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagManager do
  describe '#local_domain?' do
    # The following comparisons MUST be case-insensitive.

    around do |example|
      original_local_domain = Rails.configuration.x.local_domain
      Rails.configuration.x.local_domain = 'domain.example.com'

      example.run

      Rails.configuration.x.local_domain = original_local_domain
    end

    it 'returns true for nil' do
      expect(described_class.instance.local_domain?(nil)).to be true
    end

    it 'returns true if the slash-stripped string equals to local domain' do
      expect(described_class.instance.local_domain?('DoMaIn.Example.com/')).to be true
    end

    it 'returns false for irrelevant string' do
      expect(described_class.instance.local_domain?('DoMaIn.Example.com!')).to be false
    end
  end

  describe '#web_domain?' do
    # The following comparisons MUST be case-insensitive.

    around do |example|
      original_web_domain = Rails.configuration.x.web_domain
      Rails.configuration.x.web_domain = 'domain.example.com'

      example.run

      Rails.configuration.x.web_domain = original_web_domain
    end

    it 'returns true for nil' do
      expect(described_class.instance.web_domain?(nil)).to be true
    end

    it 'returns true if the slash-stripped string equals to web domain' do
      expect(described_class.instance.web_domain?('DoMaIn.Example.com/')).to be true
    end

    it 'returns false for string with irrelevant characters' do
      expect(described_class.instance.web_domain?('DoMaIn.Example.com!')).to be false
    end
  end

  describe '#normalize_domain' do
    it 'returns nil if the given parameter is nil' do
      expect(described_class.instance.normalize_domain(nil)).to be_nil
    end

    it 'returns normalized domain' do
      expect(described_class.instance.normalize_domain('DoMaIn.Example.com/')).to eq 'domain.example.com'
    end
  end

  describe '#local_url?' do
    around do |example|
      original_web_domain = Rails.configuration.x.web_domain
      example.run
      Rails.configuration.x.web_domain = original_web_domain
    end

    it 'returns true if the normalized string with port is local URL' do
      Rails.configuration.x.web_domain = 'domain.example.com:42'
      expect(described_class.instance.local_url?('https://DoMaIn.Example.com:42/')).to be true
    end

    it 'returns true if the normalized string without port is local URL' do
      Rails.configuration.x.web_domain = 'domain.example.com'
      expect(described_class.instance.local_url?('https://DoMaIn.Example.com/')).to be true
    end

    it 'returns false for string with irrelevant characters' do
      Rails.configuration.x.web_domain = 'domain.example.com'
      expect(described_class.instance.local_url?('https://domain.example.net/')).to be false
    end
  end
end
