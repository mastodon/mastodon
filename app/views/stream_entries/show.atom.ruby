Nokogiri::XML::Builder.new do |xml|
  entry(xml, true) do
    author(xml) do
      include_author xml, @stream_entry.account
    end

    include_entry xml, @stream_entry
  end
end.to_xml
