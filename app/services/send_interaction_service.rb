# frozen_string_literal: true

class SendInteractionService < BaseService
  # Send an Atom representation of an interaction to a remote Salmon endpoint
  # @param [StreamEntry] stream_entry
  # @param [Account] target_account
  def call(stream_entry, target_account)
    envelope = salmon.pack(entry_xml(stream_entry), stream_entry.account.keypair)
    salmon.post(target_account.salmon_url, envelope)
  end

  private

  def entry_xml(stream_entry)
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        author(xml) do
          include_author xml, stream_entry.account
        end

        include_entry xml, stream_entry
      end
    end.to_xml
  end

  def salmon
    @salmon ||= OStatus2::Salmon.new
  end
end
