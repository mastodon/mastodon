require 'mime/type'

# A version of MIME::Type that works hand-in-hand with a MIME::Types::Columnar
# container to load data by columns.
#
# When a field is has not yet been loaded, that data will be loaded for all
# types in the container before forwarding the message to MIME::Type.
#
# More information can be found in MIME::Types::Columnar.
#
# MIME::Type::Columnar is *not* intended to be created except by
# MIME::Types::Columnar containers.
class MIME::Type::Columnar < MIME::Type
  def initialize(container, content_type, extensions) # :nodoc:
    @container = container
    self.content_type = content_type
    self.extensions = extensions
  end

  def self.column(*methods, file: nil) # :nodoc:
    file = methods.first unless file

    file_method = :"load_#{file}"
    methods.each do |m|
      define_method m do |*args|
        @container.send(file_method)
        super(*args)
      end
    end
  end

  column :friendly
  column :encoding, :encoding=
  column :docs, :docs=
  column :preferred_extension, :preferred_extension=
  column :obsolete, :obsolete=, :obsolete?, :registered, :registered=,
    :registered?, :signature, :signature=, :signature?, file: 'flags'
  column :xrefs, :xrefs=, :xref_urls
  column :use_instead, :use_instead=

  def encode_with(coder) # :nodoc:
    @container.send(:load_friendly)
    @container.send(:load_encoding)
    @container.send(:load_docs)
    @container.send(:load_flags)
    @container.send(:load_use_instead)
    @container.send(:load_xrefs)
    @container.send(:load_preferred_extension)
    super
  end

  class << self
    undef column
  end
end
