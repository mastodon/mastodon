require 'spec_helper_integration'

describe RedirectUriValidator do
  subject do
    FactoryBot.create(:application)
  end

  it 'is valid when the uri is a uri' do
    subject.redirect_uri = 'https://example.com/callback'
    expect(subject).to be_valid
  end

  # Most mobile and desktop operating systems allow apps to register a custom URL
  # scheme that will launch the app when a URL with that scheme is visited from
  # the system browser.
  #
  # @see https://www.oauth.com/oauth2-servers/redirect-uris/redirect-uris-native-apps/
  it 'is valid when the uri is custom native URI' do
    subject.redirect_uri = 'myapp://callback'
    expect(subject).to be_valid
  end

  it 'is valid when the uri has a query parameter' do
    subject.redirect_uri = 'https://example.com/abcd?xyz=123'
    expect(subject).to be_valid
  end

  it 'accepts native redirect uri' do
    subject.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    expect(subject).to be_valid
  end

  it 'rejects if test uri is disabled' do
    allow(RedirectUriValidator).to receive(:native_redirect_uri).and_return(nil)
    subject.redirect_uri = 'urn:some:test'
    expect(subject).not_to be_valid
  end

  it 'is invalid when the uri is not a uri' do
    subject.redirect_uri = ']'
    expect(subject).not_to be_valid
    expect(subject.errors[:redirect_uri].first).to eq('must be a valid URI.')
  end

  it 'is invalid when the uri is relative' do
    subject.redirect_uri = '/abcd'
    expect(subject).not_to be_valid
    expect(subject.errors[:redirect_uri].first).to eq('must be an absolute URI.')
  end

  it 'is invalid when the uri has a fragment' do
    subject.redirect_uri = 'https://example.com/abcd#xyz'
    expect(subject).not_to be_valid
    expect(subject.errors[:redirect_uri].first).to eq('cannot contain a fragment.')
  end

  context 'force secured uri' do
    it 'accepts an valid uri' do
      subject.redirect_uri = 'https://example.com/callback'
      expect(subject).to be_valid
    end

    it 'accepts native redirect uri' do
      subject.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      expect(subject).to be_valid
    end

    it 'accepts app redirect uri' do
      subject.redirect_uri = 'some-awesome-app://oauth/callback'
      expect(subject).to be_valid
    end

    it 'accepts a non secured protocol when disabled' do
      subject.redirect_uri = 'http://example.com/callback'
      allow(Doorkeeper.configuration).to receive(
                                             :force_ssl_in_redirect_uri
                                         ).and_return(false)
      expect(subject).to be_valid
    end

    it 'accepts a non secured protocol when conditional option defined' do
      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        force_ssl_in_redirect_uri { |uri| uri.host != 'localhost' }
      end

      application = FactoryBot.build(:application, redirect_uri: 'http://localhost/callback')
      expect(application).to be_valid

      application = FactoryBot.build(:application, redirect_uri: 'http://localhost2/callback')
      expect(application).not_to be_valid
    end

    it 'forbids redirect uri if required' do
      subject.redirect_uri = 'javascript://document.cookie'

      Doorkeeper.configure do
        orm DOORKEEPER_ORM
        forbid_redirect_uri { |uri| uri.scheme == 'javascript' }
      end

      expect(subject).to be_invalid
      expect(subject.errors[:redirect_uri].first).to eq('is forbidden by the server.')

      subject.redirect_uri = 'https://localhost/callback'
      expect(subject).to be_valid
    end

    it 'invalidates the uri when the uri does not use a secure protocol' do
      subject.redirect_uri = 'http://example.com/callback'
      expect(subject).not_to be_valid
      error = subject.errors[:redirect_uri].first
      expect(error).to eq('must be an HTTPS/SSL URI.')
    end
  end

  context 'multiple redirect uri' do
    it 'invalidates the second uri when the first uri is native uri' do
      subject.redirect_uri = "urn:ietf:wg:oauth:2.0:oob\nexample.com/callback"
      expect(subject).to be_invalid
    end
  end
end
