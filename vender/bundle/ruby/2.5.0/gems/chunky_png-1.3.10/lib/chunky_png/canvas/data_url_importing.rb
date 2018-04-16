module ChunkyPNG
  class Canvas

    # Methods to import a canvas from a PNG data URL.
    module DataUrlImporting

      # Imports a canvas from a PNG data URL.
      # @param [String] string The data URL string to load from.
      # @return [Canvas] The imported canvas.
      # @raise ChunkyPNG::SignatureMismatch if the provides string is not a properly
      #    formatted PNG data URL (i.e. it should start with "data:image/png;base64,")
      def from_data_url(string)
        if string =~ %r[^data:image/png;base64,((?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?)$]
          from_blob($1.unpack('m').first)
        else
          raise SignatureMismatch, "The string was not a properly formatted data URL for a PNG image."
        end
      end
    end
  end
end
