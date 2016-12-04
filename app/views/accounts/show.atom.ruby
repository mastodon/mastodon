# frozen_string_literal: true

Nokogiri::XML::Builder.new do |xml|
  feed(xml) do
    simple_id  xml, account_url(@account, format: 'atom')
    title      xml, @account.display_name
    subtitle   xml, @account.note
    updated_at xml, stream_updated_at
    logo       xml, full_asset_url(@account.avatar.expiring_url(s3_expiry, :original))

    author(xml) do
      include_author xml, @account
    end

    link_alternate xml, TagManager.instance.url_for(@account)
    link_self      xml, account_url(@account, format: 'atom')
    link_hub       xml, api_push_url
    link_hub       xml, Rails.configuration.x.hub_url
    link_salmon    xml, api_salmon_url(@account.id)

    @entries.each do |stream_entry|
      entry(xml, false) do
        include_entry xml, stream_entry
      end
    end
  end
end.to_xml
