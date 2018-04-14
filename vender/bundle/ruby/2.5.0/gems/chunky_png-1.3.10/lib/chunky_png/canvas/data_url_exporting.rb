module ChunkyPNG
  class Canvas

    # Methods to export a canvas to a PNG data URL.
    module DataUrlExporting

      # Exports the canvas as a data url (e.g. data:image/png;base64,<data>) that can
      # easily be used inline in CSS or HTML.
      # @return [String] The canvas formatted as a data URL string.
      def to_data_url
        ['data:image/png;base64,', to_blob].pack('A*m').gsub(/\n/, '')
      end
    end
  end
end
