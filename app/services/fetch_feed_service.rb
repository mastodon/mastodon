class FetchFeedService
  def call(account)
    process_service.(http_client.get(account.remote_url), account)
  end

  private

  def process_service
    ProcessFeedService.new
  end

  def http_client
    HTTP
  end
end
