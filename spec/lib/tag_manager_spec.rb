require 'rails_helper'

RSpec.describe TagManager do
  describe '#local_domain?' do
    # The following comparisons MUST be case-insensitive.

    around do |example|
      original_local_domain = Rails.configuration.x.local_domain
      Rails.configuration.x.local_domain = 'domain.test'

      example.run

      Rails.configuration.x.local_domain = original_local_domain
    end

    it 'returns true for nil' do
      expect(TagManager.instance.local_domain?(nil)).to eq true
    end

    it 'returns true if the slash-stripped string equals to local domain' do
      expect(TagManager.instance.local_domain?('DoMaIn.Test/')).to eq true
    end

    it 'returns false for irrelevant string' do
      expect(TagManager.instance.local_domain?('DoMaIn.Test!')).to eq false
    end
  end

  describe '#web_domain?' do
    # The following comparisons MUST be case-insensitive.

    around do |example|
      original_web_domain = Rails.configuration.x.web_domain
      Rails.configuration.x.web_domain = 'domain.test'

      example.run

      Rails.configuration.x.web_domain = original_web_domain
    end

    it 'returns true for nil' do
      expect(TagManager.instance.web_domain?(nil)).to eq true
    end

    it 'returns true if the slash-stripped string equals to web domain' do
      expect(TagManager.instance.web_domain?('DoMaIn.Test/')).to eq true
    end

    it 'returns false for string with irrelevant characters' do
      expect(TagManager.instance.web_domain?('DoMaIn.Test!')).to eq false
    end
  end

  describe '#normalize_domain' do
    it 'returns nil if the given parameter is nil' do
      expect(TagManager.instance.normalize_domain(nil)).to eq nil
    end

    it 'returns normalized domain' do
      expect(TagManager.instance.normalize_domain('DoMaIn.Test/')).to eq 'domain.test'
    end
  end

  describe '#local_url?' do
    around do |example|
      original_web_domain = Rails.configuration.x.web_domain
      example.run
      Rails.configuration.x.web_domain = original_web_domain
    end

    it 'returns true if the normalized string with port is local URL' do
      Rails.configuration.x.web_domain = 'domain.test:42'
      expect(TagManager.instance.local_url?('https://DoMaIn.Test:42/')).to eq true
    end

    it 'returns true if the normalized string without port is local URL' do
      Rails.configuration.x.web_domain = 'domain.test'
      expect(TagManager.instance.local_url?('https://DoMaIn.Test/')).to eq true
    end

    it 'returns false for string with irrelevant characters' do
      Rails.configuration.x.web_domain = 'domain.test'
      expect(TagManager.instance.local_url?('https://domainn.test/')).to eq false
    end
  end
end
