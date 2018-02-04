Nokogiri::XML::Builder.new do |xml|
  xml.XRD(xmlns: 'http://docs.oasis-open.org/ns/xri/xrd-1.0') do
    xml.Subject @account.to_webfinger_s
    xml.Alias short_account_url(@account)
    xml.Alias account_url(@account)
    xml.Link(rel: 'http://webfinger.net/rel/profile-page', type: 'text/html', href: short_account_url(@account))
    xml.Link(rel: 'http://schemas.google.com/g/2010#updates-from', type: 'application/atom+xml', href: account_url(@account, format: 'atom'))
    xml.Link(rel: 'self', type: 'application/activity+json', href: account_url(@account))
    xml.Link(rel: 'salmon', href: api_salmon_url(@account.id))
    xml.Link(rel: 'magic-public-key', href: "data:application/magic-public-key,#{@account.magic_key}")
    xml.Link(rel: 'http://ostatus.org/schema/1.0/subscribe', template: "#{authorize_follow_url}?acct={uri}")
  end
end.to_xml
