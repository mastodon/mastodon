Nokogiri::XML::Builder.new do |xml|
  xml.XRD(xmlns: 'http://docs.oasis-open.org/ns/xri/xrd-1.0') do
    xml.Subject @canonical_account_uri
    xml.Alias profile_url(name: @account.username)
    xml.Link(rel: 'http://webfinger.net/rel/profile-page', type: 'text/html', href: profile_url(name: @account.username))
    xml.Link(rel: 'http://schemas.google.com/g/2010#updates-from', type: 'application/atom+xml', href: atom_user_stream_url(id: @account.id))
    xml.Link(rel: 'salmon', href: salmon_url(@account))
    xml.Link(rel: 'magic-public-key', href: @magic_key)
  end
end.to_xml
