# frozen_string_literal: true

module StreamEntryRenderer
  def stream_entry_to_xml(stream_entry)
    AtomSerializer.render(AtomSerializer.new.entry(stream_entry, true))
  end
end
