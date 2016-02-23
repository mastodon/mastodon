Nokogiri::XML::Builder.new do |xml|
  feed(xml) do
    simple_id  xml, atom_user_stream_url(id: @account.id)
    title      xml, @account.display_name
    subtitle   xml, @account.note
    updated_at xml, stream_updated_at

    author(xml) do
      include_author xml, @account
    end

    link_alternate xml, profile_url(name: @account.username)
    link_self      xml, atom_user_stream_url(id: @account.id)
    link_hub       xml, HUB_URL
    link_salmon    xml, salmon_url(@account)

    @account.stream_entries.order('id desc').each do |stream_entry|
      entry(xml, false) do
        include_entry xml, stream_entry
      end
    end
  end
end.to_xml
