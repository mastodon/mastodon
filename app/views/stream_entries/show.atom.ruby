Nokogiri::XML::Builder.new do |xml|
  entry(xml, true) do
    author(xml) do
      include_author xml, @entry.account
    end

    include_entry xml, @entry
  end
end.to_xml
