class ProcessFeedService
  def call(body, account)
    xml = Nokogiri::XML(body)

    xml.xpath('/xmlns:feed/xmlns:entry').each do |entry|
      uri    = entry.at_xpath('./xmlns:id').content
      status = Status.find_by(uri: uri)

      next if !status.nil?

      status = Status.new
      status.account    = account
      status.uri        = uri
      status.text       = entry.at_xpath('./xmlns:content').content
      status.created_at = entry.at_xpath('./xmlns:published').content
      status.updated_at = entry.at_xpath('./xmlns:updated').content
      status.save!

      # todo: not everything is a status. there are follows, favourites
      # todo: RTs
    end
  end
end
