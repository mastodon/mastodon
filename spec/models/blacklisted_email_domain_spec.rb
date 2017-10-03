require 'rails_helper'

RSpec.describe BlacklistedEmailDomain, type: :model do
  describe 'validations' do
    it 'has a valid fabricator' do
      blacklisted_email_domain = Fabricate.build(:blacklisted_email_domain)
      expect(blacklisted_email_domain).to be_valid
    end
  end

  describe 'block?' do
    it 'returns true if the domain is registed' do
      Fabricate(:blacklisted_email_domain, domain: 'example.com')
      expect(BlacklistedEmailDomain.block?('nyarn@example.com')).to eq true
    end
    it 'returns true if the domain is not registed' do
      Fabricate(:blacklisted_email_domain, domain: 'domain')
      expect(BlacklistedEmailDomain.block?('example')).to eq false
    end
  end
end
