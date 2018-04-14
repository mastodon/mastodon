# frozen_string_literal: true

module MIME
  class Types
    module Data
      VERSION = '3.2016.0521'

      # The path that will be used for loading the MIME::Types data. The
      # default location is __FILE__/../../../../data, which is where the data
      # lives in the gem installation of the mime-types-data library.
      #
      # The MIME::Types::Loader will load all JSON or columnar files contained
      # in this path.
      #
      # System maintainer note: this is the constant to change when packaging
      # mime-types for your system. It is recommended that the path be
      # something like /usr/share/ruby/mime-types/.
      PATH = File.expand_path('../../../../data', __FILE__)
    end
  end
end
