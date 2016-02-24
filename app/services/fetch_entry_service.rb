class FetchEntryService < BaseService
  # Knowing nothing but the URL of a remote status, create a local representation of it and return it
  # @param [String] url Atom URL
  # @return [Status]
  def call(url)
    body = http_client.get(url)
    xml  = Nokogiri::XML(body)
    # todo
  end

  private

  def http_client
    HTTP
  end
end
