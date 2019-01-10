doc = Ox::Document.new(version: '1.0')

doc << Ox::Element.new('XRD').tap do |xrd|
  xrd['xmlns'] = 'http://docs.oasis-open.org/ns/xri/xrd-1.0'

  xrd << (Ox::Element.new('Subject') << @account.to_webfinger_s)
  xrd << (Ox::Element.new('Alias') << short_account_url(@account))
  xrd << (Ox::Element.new('Alias') << account_url(@account))

  xrd << Ox::Element.new('Link').tap do |link|
    link['rel']      = 'http://webfinger.net/rel/profile-page'
    link['type']     = 'text/html'
    link['href']     = short_account_url(@account)
  end

  xrd << Ox::Element.new('Link').tap do |link|
    link['rel']      = 'http://schemas.google.com/g/2010#updates-from'
    link['type']     = 'application/atom+xml'
    link['href']     = account_url(@account, format: 'atom')
  end

  xrd << Ox::Element.new('Link').tap do |link|
    link['rel']      = 'self'
    link['type']     = 'application/activity+json'
    link['href']     = account_url(@account)
  end

  xrd << Ox::Element.new('Link').tap do |link|
    link['rel']      = 'salmon'
    link['href']     = api_salmon_url(@account.id)
  end

  xrd << Ox::Element.new('Link').tap do |link|
    link['rel']      = 'magic-public-key'
    link['href']     = "data:application/magic-public-key,#{@account.magic_key}"
  end

  xrd << Ox::Element.new('Link').tap do |link|
    link['rel']      = 'http://ostatus.org/schema/1.0/subscribe'
    link['template'] = "#{authorize_interaction_url}?acct={uri}"
  end
end

('<?xml version="1.0" encoding="UTF-8"?>' + Ox.dump(doc, effort: :tolerant)).force_encoding('UTF-8')
