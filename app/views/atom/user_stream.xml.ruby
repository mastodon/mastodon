Nokogiri::XML::Builder.new do |xml|
  feed(xml) do
    simple_id  xml, atom_user_stream_url(id: @account.id)
    title      xml, @account.display_name
    subtitle   xml, @account.note
    updated_at xml, stream_updated_at

    author(xml) do
      object_type      xml, :person
      uri              xml, profile_url(name: @account.username)
      name             xml, @account.username
      summary          xml, @account.note
      link_alternate   xml, profile_url(name: @account.username)
      portable_contact xml, @account
    end

    link_alternate xml, profile_url(name: @account.username)
    link_self      xml, atom_user_stream_url(id: @account.id)
    link_hub       xml, HUB_URL
    link_salmon    xml, salmon_url(@account)

    @account.stream_entries.order('id desc').each do |stream_entry|
      entry(xml, false) do
        unique_id    xml, stream_entry.created_at, stream_entry.activity_id, stream_entry.activity_type
        published_at xml, stream_entry.activity.created_at
        updated_at   xml, stream_entry.activity.updated_at
        title        xml, stream_entry.title
        content      xml, stream_entry.content
        verb         xml, stream_entry.verb
        link_self    xml, atom_entry_url(id: stream_entry.id)

        if stream_entry.targeted?
          target(xml) do
            object_type    xml, stream_entry.target.object_type
            simple_id      xml, stream_entry.target.uri
            title          xml, stream_entry.target.title
            summary        xml, stream_entry.target.summary
            link_alternate xml, stream_entry.target.uri

            if stream_entry.target.object_type == :person
              portable_contact xml, stream_entry.target
            end
          end
        else
          object_type xml, stream_entry.object_type
        end
      end
    end
  end
end.to_xml
