module Paperclip
  # A base error class for Paperclip. Most of the error that will be thrown
  # from Paperclip will inherits from this class.
  class Error < StandardError
  end

  module Errors
    # Will be thrown when a storage method is not found.
    class StorageMethodNotFound < Paperclip::Error
    end

    # Will be thrown when a command or executable is not found.
    class CommandNotFoundError < Paperclip::Error
    end

    # Attachments require a content_type or file_name validator,
    # or to have explicitly opted out of them.
    class MissingRequiredValidatorError < Paperclip::Error
    end

    # Will be thrown when ImageMagic cannot determine the uploaded file's
    # metadata, usually this would mean the file is not an image. If you are
    # consistently receiving this error on PDFs make sure that you have
    # installed Ghostscript.
    class NotIdentifiedByImageMagickError < Paperclip::Error
    end

    # Will be thrown if the interpolation is creating an infinite loop. If you
    # are creating an interpolator which might cause an infinite loop, you
    # should be throwing this error upon the infinite loop as well.
    class InfiniteInterpolationError < Paperclip::Error
    end
  end
end
