# frozen_string_literal: true

module Paperclip
  module AttachmentExtensions
    def meta
      instance_read(:meta)
    end

    # monkey-patch to avoid unlinking too avoid unlinking source file too early
    # see https://github.com/kreeti/kt-paperclip/issues/64
    def post_process_style(name, style) #:nodoc:
      raise "Style #{name} has no processors defined." if style.processors.blank?

      intermediate_files = []
      original = @queued_for_write[:original]
      # if we're processing the original, close + unlink the source tempfile
      intermediate_files << original if name == :original

      @queued_for_write[name] = style.processors.
                                inject(original) do |file, processor|
        file = Paperclip.processor(processor).make(file, style.processor_options, self)
        intermediate_files << file unless file == original
        file
      end

      unadapted_file = @queued_for_write[name]
      @queued_for_write[name] = Paperclip.io_adapters.
                                for(@queued_for_write[name], @options[:adapter_options])
      unadapted_file.close if unadapted_file.respond_to?(:close)
      @queued_for_write[name]
    rescue Paperclip::Errors::NotIdentifiedByImageMagickError => e
      log("An error was received while processing: #{e.inspect}")
      (@errors[:processing] ||= []) << e.message if @options[:whiny]
    ensure
      unlink_files(intermediate_files)
    end

    # We overwrite this method to support delayed processing in
    # Sidekiq. Since we process the original file to reduce disk
    # usage, and we still want to generate thumbnails straight
    # away, it's the only style we need to exclude
    def process_style?(style_name, style_args)
      if style_name == :original && instance.respond_to?(:delay_processing_for_attachment?) && instance.delay_processing_for_attachment?(name)
        false
      else
        style_args.empty? || style_args.include?(style_name)
      end
    end

    def storage_schema_version
      instance_read(:storage_schema_version) || 0
    end

    def assign_attributes
      super
      instance_write(:storage_schema_version, 1)
    end

    def variant?(other_filename)
      return true  if original_filename == other_filename
      return false if original_filename.nil?

      formats = styles.values.filter_map(&:format)

      return false if formats.empty?

      other_extension = File.extname(other_filename)

      formats.include?(other_extension.delete('.')) && File.basename(other_filename, other_extension) == File.basename(original_filename, File.extname(original_filename))
    end

    def default_url(style_name = default_style)
      @url_generator.for_as_default(style_name)
    end

    STOPLIGHT_THRESHOLD = 10
    STOPLIGHT_COOLDOWN  = 30

    # We overwrite this method to put a circuit breaker around
    # calls to object storage, to stop hitting APIs that are slow
    # to respond or don't respond at all and as such minimize the
    # impact of object storage outages on application throughput
    def save
      # Don't go through Stoplight if we don't have anything object-storage-oriented to do
      return super if @queued_for_delete.empty? && @queued_for_write.empty? && !dirty?

      Stoplight('object-storage') { super }.with_threshold(STOPLIGHT_THRESHOLD).with_cool_off_time(STOPLIGHT_COOLDOWN).with_error_handler do |error, handle|
        if error.is_a?(Seahorse::Client::NetworkingError)
          handle.call(error)
        else
          raise error
        end
      end.run
    end
  end
end

Paperclip::Attachment.prepend(Paperclip::AttachmentExtensions)
