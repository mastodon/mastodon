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

  describe '#same_acct?' do
    # The following comparisons MUST be case-insensitive.

    it 'returns true if the needle has a correct username and domain for remote user' do
      expect(TagManager.instance.same_acct?('username@domain.test', 'UsErNaMe@DoMaIn.Test')).to eq true
    end

    it 'returns false if the needle is missing a domain for remote user' do
      expect(TagManager.instance.same_acct?('username@domain.test', 'UsErNaMe')).to eq false
    end

    it 'returns false if the needle has an incorrect domain for remote user' do
      expect(TagManager.instance.same_acct?('username@domain.test', 'UsErNaMe@incorrect.test')).to eq false
    end

    it 'returns false if the needle has an incorrect username for remote user' do
      expect(TagManager.instance.same_acct?('username@domain.test', 'incorrect@DoMaIn.test')).to eq false
    end

    it 'returns true if the needle has a correct username and domain for local user' do
      expect(TagManager.instance.same_acct?('username', 'UsErNaMe@Cb6E6126.nGrOk.Io')).to eq true
    end

    it 'returns true if the needle is missing a domain for local user' do
      expect(TagManager.instance.same_acct?('username', 'UsErNaMe')).to eq true
    end

    it 'returns false if the needle has an incorrect username for local user' do
      expect(TagManager.instance.same_acct?('username', 'UsErNaM@Cb6E6126.nGrOk.Io')).to eq false
    end

    it 'returns false if the needle has an incorrect domain for local user' do
      expect(TagManager.instance.same_acct?('username', 'incorrect@Cb6E6126.nGrOk.Io')).to eq false
    end
  end

  describe '#url_for' do
    let(:alice) { Fabricate(:account, username: 'alice') }

    subject { TagManager.instance.url_for(target) }

    context 'activity object' do
      let(:target) { Fabricate(:status, account: alice, reblog: Fabricate(:status)).stream_entry }

      it 'returns the unique tag for status' do
        expect(target.object_type).to eq :activity
        is_expected.to eq "https://cb6e6126.ngrok.io/@alice/#{target.id}"
      end
    end

    context 'comment object' do
      let(:target) { Fabricate(:status, account: alice, reply: true) }

      it 'returns the unique tag for status' do
        expect(target.object_type).to eq :comment
        is_expected.to eq "https://cb6e6126.ngrok.io/@alice/#{target.id}"
      end
    end

    context 'note object' do
      let(:target) { Fabricate(:status, account: alice, reply: false, thread: nil) }

      it 'returns the unique tag for status' do
        expect(target.object_type).to eq :note
        is_expected.to eq "https://cb6e6126.ngrok.io/@alice/#{target.id}"
      end
    end

    context 'person object' do
      let(:target) { alice }

      it 'returns the URL for account' do
        expect(target.object_type).to eq :person
        is_expected.to eq 'https://cb6e6126.ngrok.io/@alice'
      end
    end
  end
end
