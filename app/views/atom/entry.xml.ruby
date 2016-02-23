Nokogiri::XML::Builder.new do |xml|
  entry(xml, true) do
    unique_id    xml, @entry.created_at, @entry.activity_id, @entry.activity_type
    published_at xml, @entry.activity.created_at
    updated_at   xml, @entry.activity.updated_at
    title        xml, @entry.title
    content      xml, @entry.content
    verb         xml, @entry.verb

    author(xml) do
      object_type      xml, :person
      uri              xml, profile_url(name: @entry.account.username)
      name             xml, @entry.account.username
      summary          xml, @entry.account.note
      link_alternate   xml, profile_url(name: @entry.account.username)
      portable_contact xml, @entry.account
    end

    if @entry.targeted?
      target(xml) do
        object_type    xml, @entry.target.object_type
        simple_id      xml, @entry.target.uri
        title          xml, @entry.target.title
        summary        xml, @entry.target.summary
        link_alternate xml, @entry.target.uri

        if @entry.target.object_type == :person
          portable_contact xml, @entry.target
        end
      end
    else
      object_type xml, @entry.object_type
    end

    link_self xml, atom_entry_url(id: @entry.id)
  end
end
