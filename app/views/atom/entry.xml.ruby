Nokogiri::XML::Builder.new do |xml|
  xml.entry(xmlns: 'http://www.w3.org/2005/Atom', 'xmlns:thr': 'http://purl.org/syndication/thread/1.0', 'xmlns:activity': 'http://activitystrea.ms/spec/1.0/', 'xmlns:poco': 'http://portablecontacts.net/spec/1.0') do
    xml.id_ unique_tag(@entry.created_at, @entry.activity_id, @entry.activity_type)

    xml.published @entry.activity.created_at.iso8601
    xml.updated   @entry.activity.updated_at.iso8601

    xml.title @entry.title
    xml.content({ type: 'html' }, @entry.content)
    xml['activity'].send('verb', "http://activitystrea.ms/schema/1.0/#{@entry.verb}")

    xml.author do
      xml['activity'].send('object-type', 'http://activitystrea.ms/schema/1.0/person')
      xml.uri profile_url(name: @entry.account.username)
      xml.name @entry.account.username
      xml.summary @entry.account.note

      xml.link(rel: 'alternate', type: 'text/html', href: profile_url(name: @entry.account.username))

      xml['poco'].preferredUsername @entry.account.username
      xml['poco'].displayName @entry.account.display_name
      xml['poco'].note @entry.account.note
    end

    if @entry.targeted?
      xml['activity'].send('object') do
        xml['activity'].send('object-type', "http://activitystrea.ms/schema/1.0/#{@entry.target.object_type}")
        xml.id_ @entry.target.uri
        xml.title @entry.target.title
        xml.summary @entry.target.summary
        xml.link(rel: 'alternate', type: 'text/html', href: @entry.target.uri)
      end
    else
      xml['activity'].send('object-type', "http://activitystrea.ms/schema/1.0/#{@entry.object_type}")
    end

    xml.link(rel: 'self', type: 'application/atom+xml', href: atom_entry_url(id: @entry.id))
  end
end.to_xml
