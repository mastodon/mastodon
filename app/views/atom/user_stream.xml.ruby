Nokogiri::XML::Builder.new do |xml|
  xml.feed(xmlns: 'http://www.w3.org/2005/Atom', 'xmlns:thr': 'http://purl.org/syndication/thread/1.0', 'xmlns:activity': 'http://activitystrea.ms/spec/1.0/') do
    xml.id_ atom_user_stream_url(id: @account.id)
    xml.title @account.display_name
    xml.subtitle @account.note
    xml.updated stream_updated_at

    xml.author do
      xml['activity'].send('object-type', 'http://activitystrea.ms/schema/1.0/person')
      xml.uri profile_url(name: @account.username)
      xml.name @account.username
      xml.summary @account.note

      xml.link(rel: 'alternate', type: 'text/html', href: profile_url(name: @account.username))
    end

    xml.link(rel: 'alternate', type: 'text/html', href: profile_url(name: @account.username))
    xml.link(rel: 'hub', href: HUB_URL)
    xml.link(rel: 'salmon', href: salmon_url(@account))
    xml.link(rel: 'self', type: 'application/atom+xml', href: atom_user_stream_url(id: @account.id))

    @account.stream_entries.each do |stream_entry|
      xml.entry do
        xml.id_ unique_tag(stream_entry.created_at, stream_entry.activity_id, stream_entry.activity_type)

        xml.published stream_entry.activity.created_at.iso8601
        xml.updated   stream_entry.activity.updated_at.iso8601

        xml.title stream_entry.title
        xml.content({ type: 'html' }, stream_entry.content)
        xml['activity'].send('verb', "http://activitystrea.ms/schema/1.0/#{stream_entry.verb}")

        if stream_entry.targeted?
          xml['activity'].send('object') do
            xml['activity'].send('object-type', "http://activitystrea.ms/schema/1.0/#{stream_entry.target.object_type}")
            xml.id_ stream_entry.target.uri
          end
        else
          xml['activity'].send('object-type', "http://activitystrea.ms/schema/1.0/#{stream_entry.object_type}")
        end
      end
    end
  end
end.to_xml
