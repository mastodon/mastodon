module Paperclip
  # Paperclip processors allow you to modify attached files when they are
  # attached in any way you are able. Paperclip itself uses command-line
  # programs for its included Thumbnail processor, but custom processors
  # are not required to follow suit.
  #
  # Processors are required to be defined inside the Paperclip module and
  # are also required to be a subclass of Paperclip::Processor. There is
  # only one method you *must* implement to properly be a subclass:
  # #make, but #initialize may also be of use. #initialize accepts 3
  # arguments: the file that will be operated on (which is an instance of
  # File), a hash of options that were defined in has_attached_file's
  # style hash, and the Paperclip::Attachment itself. These are set as
  # instance variables that can be used within `#make`.
  #
  # #make must return an instance of File (Tempfile is acceptable) which
  # contains the results of the processing.
  #
  # See Paperclip.run for more information about using command-line
  # utilities from within Processors.
  class Processor
    attr_accessor :file, :options, :attachment

    def initialize file, options = {}, attachment = nil
      @file = file
      @options = options
      @attachment = attachment
    end

    def make
    end

    def self.make file, options = {}, attachment = nil
      new(file, options, attachment).make
    end

    # The convert method runs the convert binary with the provided arguments.
    # See Paperclip.run for the available options.
    def convert(arguments = "", local_options = {})
      Paperclip.run('convert', arguments, local_options)
    end

    # The identify method runs the identify binary with the provided arguments.
    # See Paperclip.run for the available options.
    def identify(arguments = "", local_options = {})
      Paperclip.run('identify', arguments, local_options)
    end
  end
end
