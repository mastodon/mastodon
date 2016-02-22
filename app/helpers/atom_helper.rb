module AtomHelper
  def stream_updated_at
    @account.stream_entries.last ? @account.stream_entries.last.created_at.iso8601 : @account.updated_at.iso8601
  end
end
