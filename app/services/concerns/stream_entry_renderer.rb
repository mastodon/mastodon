# frozen_string_literal: true

module StreamEntryRenderer
  def stream_entry_to_xml(stream_entry)
    renderer = StreamEntriesController.renderer.new(method: 'get', http_host: Rails.configuration.x.local_domain, https: Rails.configuration.x.use_https)
    renderer.render(:show, assigns: { stream_entry: stream_entry }, formats: [:atom])
  end
end
