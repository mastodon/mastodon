# encoding: utf-8
require 'uri'
require 'paperclip/url_generator'
require 'active_support/deprecation'
require 'active_support/core_ext/string/inflections'

module Paperclip
  # The Attachment class manages the files for a given attachment. It saves
  # when the model saves, deletes when the model is destroyed, and processes
  # the file upon assignment.
  class Attachment
    def self.default_options
      @default_options ||= {
        :convert_options       => {},
        :default_style         => :original,
        :default_url           => "/:attachment/:style/missing.png",
        :escape_url            => true,
        :restricted_characters => /[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# ]/,
        :filename_cleaner      => nil,
        :hash_data             => ":class/:attachment/:id/:style/:updated_at",
        :hash_digest           => "SHA1",
        :interpolator          => Paperclip::Interpolations,
        :only_process          => [],
        :path                  => ":rails_root/public:url",
        :preserve_files        => false,
        :processors            => [:thumbnail],
        :source_file_options   => {},
        :storage               => :filesystem,
        :styles                => {},
        :url                   => "/system/:class/:attachment/:id_partition/:style/:filename",
        :url_generator         => Paperclip::UrlGenerator,
        :use_default_time_zone => true,
        :use_timestamp         => true,
        :whiny                 => Paperclip.options[:whiny] || Paperclip.options[:whiny_thumbnails],
        :validate_media_type   => true,
        :adapter_options       => { hash_digest: Digest::MD5 },
        :check_validity_before_processing => true
      }
    end

    attr_reader :name, :instance, :default_style, :convert_options, :queued_for_write, :whiny,
                :options, :interpolator, :source_file_options
    attr_accessor :post_processing

    # Creates an Attachment object. +name+ is the name of the attachment,
    # +instance+ is the model object instance it's attached to, and
    # +options+ is the same as the hash passed to +has_attached_file+.
    #
    # Options include:
    #
    # +url+ - a relative URL of the attachment. This is interpolated using +interpolator+
    # +path+ - where on the filesystem to store the attachment. This is interpolated using +interpolator+
    # +styles+ - a hash of options for processing the attachment. See +has_attached_file+ for the details
    # +only_process+ - style args to be run through the post-processor. This defaults to the empty list (which is
    #                  a special case that indicates all styles should be processed)
    # +default_url+ - a URL for the missing image
    # +default_style+ - the style to use when an argument is not specified e.g. #url, #path
    # +storage+ - the storage mechanism. Defaults to :filesystem
    # +use_timestamp+ - whether to append an anti-caching timestamp to image URLs. Defaults to true
    # +whiny+, +whiny_thumbnails+ - whether to raise when thumbnailing fails
    # +use_default_time_zone+ - related to +use_timestamp+. Defaults to true
    # +hash_digest+ - a string representing a class that will be used to hash URLs for obfuscation
    # +hash_data+ - the relative URL for the hash data. This is interpolated using +interpolator+
    # +hash_secret+ - a secret passed to the +hash_digest+
    # +convert_options+ - flags passed to the +convert+ command for processing
    # +source_file_options+ - flags passed to the +convert+ command that controls how the file is read
    # +processors+ - classes that transform the attachment. Defaults to [:thumbnail]
    # +preserve_files+ - whether to keep files on the filesystem when deleting or clearing the attachment. Defaults to false
    # +filename_cleaner+ - An object that responds to #call(filename) that will strip unacceptable charcters from filename
    # +interpolator+ - the object used to interpolate filenames and URLs. Defaults to Paperclip::Interpolations
    # +url_generator+ - the object used to generate URLs, using the interpolator. Defaults to Paperclip::UrlGenerator
    # +escape_url+ - Perform URI escaping to URLs. Defaults to true
    def initialize(name, instance, options = {})
      @name              = name.to_sym
      @name_string       = name.to_s
      @instance          = instance

      options = self.class.default_options.deep_merge(options)

      @options               = options
      @post_processing       = true
      @queued_for_delete     = []
      @queued_for_write      = {}
      @errors                = {}
      @dirty                 = false
      @interpolator          = options[:interpolator]
      @url_generator         = options[:url_generator].new(self)
      @source_file_options   = options[:source_file_options]
      @whiny                 = options[:whiny]

      initialize_storage
    end

    # What gets called when you call instance.attachment = File. It clears
    # errors, assigns attributes, and processes the file. It also queues up the
    # previous file for deletion, to be flushed away on #save of its host.  In
    # addition to form uploads, you can also assign another Paperclip
    # attachment:
    #   new_user.avatar = old_user.avatar
    def assign(uploaded_file)
      @file = Paperclip.io_adapters.for(uploaded_file,
                                        @options[:adapter_options])
      ensure_required_accessors!
      ensure_required_validations!

      if @file.assignment?
        clear(*only_process)

        if @file.nil?
          nil
        else
          assign_attributes
          post_process_file
          reset_file_if_original_reprocessed
        end
      else
        nil
      end
    end

    # Returns the public URL of the attachment with a given style. This does
    # not necessarily need to point to a file that your Web server can access
    # and can instead point to an action in your app, for example for fine grained
    # security; this has a serious performance tradeoff.
    #
    # Options:
    #
    # +timestamp+ - Add a timestamp to the end of the URL. Default: true.
    # +escape+    - Perform URI escaping to the URL. Default: true.
    #
    # Global controls (set on has_attached_file):
    #
    # +interpolator+  - The object that fills in a URL pattern's variables.
    # +default_url+   - The image to show when the attachment has no image.
    # +url+           - The URL for a saved image.
    # +url_generator+ - The object that generates a URL. Default: Paperclip::UrlGenerator.
    #
    # As mentioned just above, the object that generates this URL can be passed
    # in, for finer control. This object must respond to two methods:
    #
    # +#new(Paperclip::Attachment, options_hash)+
    # +#for(style_name, options_hash)+

    def url(style_name = default_style, options = {})
      if options == true || options == false # Backwards compatibility.
        @url_generator.for(style_name, default_options.merge(:timestamp => options))
      else
        @url_generator.for(style_name, default_options.merge(options))
      end
    end

    def default_options
      {
        :timestamp => @options[:use_timestamp],
        :escape => @options[:escape_url]
      }
    end

    # Alias to +url+ that allows using the expiring_url method provided by the cloud
    # storage implementations, but keep using filesystem storage for development and
    # testing.
    def expiring_url(time = 3600, style_name = default_style)
      url(style_name)
    end

    # Returns the path of the attachment as defined by the :path option. If the
    # file is stored in the filesystem the path refers to the path of the file
    # on disk. If the file is stored in S3, the path is the "key" part of the
    # URL, and the :bucket option refers to the S3 bucket.
    def path(style_name = default_style)
      path = original_filename.nil? ? nil : interpolate(path_option, style_name)
      path.respond_to?(:unescape) ? path.unescape : path
    end

    # :nodoc:
    def staged_path(style_name = default_style)
      if staged?
        @queued_for_write[style_name].path
      end
    end

    # :nodoc:
    def staged?
      ! @queued_for_write.empty?
    end

    # Alias to +url+
    def to_s style_name = default_style
      url(style_name)
    end

    def as_json(options = nil)
      to_s((options && options[:style]) || default_style)
    end

    def default_style
      @options[:default_style]
    end

    def styles
      if @options[:styles].respond_to?(:call) || @normalized_styles.nil?
        styles = @options[:styles]
        styles = styles.call(self) if styles.respond_to?(:call)

        @normalized_styles = styles.dup
        styles.each_pair do |name, options|
          @normalized_styles[name.to_sym] = Paperclip::Style.new(name.to_sym, options.dup, self)
        end
      end
      @normalized_styles
    end

    def only_process
      only_process = @options[:only_process].dup
      only_process = only_process.call(self) if only_process.respond_to?(:call)
      only_process.map(&:to_sym)
    end

    def processors
      processing_option = @options[:processors]

      if processing_option.respond_to?(:call)
        processing_option.call(instance)
      else
        processing_option
      end
    end

    # Returns an array containing the errors on this attachment.
    def errors
      @errors
    end

    # Returns true if there are changes that need to be saved.
    def dirty?
      @dirty
    end

    # Saves the file, if there are no errors. If there are, it flushes them to
    # the instance's errors and returns false, cancelling the save.
    def save
      flush_deletes unless @options[:keep_old_files]
      process = only_process
      if process.any? && !process.include?(:original)
        @queued_for_write.except!(:original)
      end
      flush_writes
      @dirty = false
      true
    end

    # Clears out the attachment. Has the same effect as previously assigning
    # nil to the attachment. Does NOT save. If you wish to clear AND save,
    # use #destroy.
    def clear(*styles_to_clear)
      if styles_to_clear.any?
        queue_some_for_delete(*styles_to_clear)
      else
        queue_all_for_delete
        @queued_for_write  = {}
        @errors            = {}
      end
    end

    # Destroys the attachment. Has the same effect as previously assigning
    # nil to the attachment *and saving*. This is permanent. If you wish to
    # wipe out the existing attachment but not save, use #clear.
    def destroy
      clear
      save
    end

    # Returns the uploaded file if present.
    def uploaded_file
      instance_read(:uploaded_file)
    end

    # Returns the name of the file as originally assigned, and lives in the
    # <attachment>_file_name attribute of the model.
    def original_filename
      instance_read(:file_name)
    end

    # Returns the size of the file as originally assigned, and lives in the
    # <attachment>_file_size attribute of the model.
    def size
      instance_read(:file_size) || (@queued_for_write[:original] && @queued_for_write[:original].size)
    end

    # Returns the fingerprint of the file, if one's defined. The fingerprint is
    # stored in the <attachment>_fingerprint attribute of the model.
    def fingerprint
      instance_read(:fingerprint)
    end

    # Returns the content_type of the file as originally assigned, and lives
    # in the <attachment>_content_type attribute of the model.
    def content_type
      instance_read(:content_type)
    end

    # Returns the creation time of the file as originally assigned, and
    # lives in the <attachment>_created_at attribute of the model.
    def created_at
      if able_to_store_created_at?
        time = instance_read(:created_at)
        time && time.to_f.to_i
      end
    end

    # Returns the last modified time of the file as originally assigned, and
    # lives in the <attachment>_updated_at attribute of the model.
    def updated_at
      time = instance_read(:updated_at)
      time && time.to_f.to_i
    end

    # The time zone to use for timestamp interpolation.  Using the default
    # time zone ensures that results are consistent across all threads.
    def time_zone
      @options[:use_default_time_zone] ? Time.zone_default : Time.zone
    end

    # Returns a unique hash suitable for obfuscating the URL of an otherwise
    # publicly viewable attachment.
    def hash_key(style_name = default_style)
      raise ArgumentError, "Unable to generate hash without :hash_secret" unless @options[:hash_secret]
      require 'openssl' unless defined?(OpenSSL)
      data = interpolate(@options[:hash_data], style_name)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.const_get(@options[:hash_digest]).new, @options[:hash_secret], data)
    end

    # This method really shouldn't be called that often. Its expected use is
    # in the paperclip:refresh rake task and that's it. It will regenerate all
    # thumbnails forcefully, by reobtaining the original file and going through
    # the post-process again.
    # NOTE: Calling reprocess WILL NOT delete existing files. This is due to
    # inconsistencies in timing of S3 commands. It's possible that calling
    # #reprocess! will lose data if the files are not kept.
    def reprocess!(*style_args)
      saved_only_process, @options[:only_process] = @options[:only_process], style_args
      saved_preserve_files, @options[:preserve_files] = @options[:preserve_files], true
      begin
        assign(self)
        save
        instance.save
      rescue Errno::EACCES => e
        warn "#{e} - skipping file."
        false
      ensure
        @options[:only_process] = saved_only_process
        @options[:preserve_files] = saved_preserve_files
      end
    end

    # Returns true if a file has been assigned.
    def file?
      original_filename.present?
    end

    alias :present? :file?

    def blank?
      not present?
    end

    # Determines whether the instance responds to this attribute. Used to prevent
    # calculations on fields we won't even store.
    def instance_respond_to?(attr)
      instance.respond_to?(:"#{name}_#{attr}")
    end

    # Writes the attachment-specific attribute on the instance. For example,
    # instance_write(:file_name, "me.jpg") will write "me.jpg" to the instance's
    # "avatar_file_name" field (assuming the attachment is called avatar).
    def instance_write(attr, value)
      setter = :"#{@name_string}_#{attr}="
      if instance.respond_to?(setter)
        instance.send(setter, value)
      end
    end

    # Reads the attachment-specific attribute on the instance. See instance_write
    # for more details.
    def instance_read(attr)
      getter = :"#{@name_string}_#{attr}"
      if instance.respond_to?(getter)
        instance.send(getter)
      end
    end

    private

    def path_option
      @options[:path].respond_to?(:call) ? @options[:path].call(self) : @options[:path]
    end

    def active_validator_classes
      @instance.class.validators.map(&:class)
    end

    def missing_required_validator?
      (active_validator_classes.flat_map(&:ancestors) & Paperclip::REQUIRED_VALIDATORS).empty?
    end

    def ensure_required_validations!
      if missing_required_validator?
        raise Paperclip::Errors::MissingRequiredValidatorError
      end
    end

    def ensure_required_accessors! #:nodoc:
      %w(file_name).each do |field|
        unless @instance.respond_to?("#{@name_string}_#{field}") && @instance.respond_to?("#{@name_string}_#{field}=")
          raise Paperclip::Error.new("#{@instance.class} model missing required attr_accessor for '#{@name_string}_#{field}'")
        end
      end
    end

    def log message #:nodoc:
      Paperclip.log(message)
    end

    def initialize_storage #:nodoc:
      storage_class_name = @options[:storage].to_s.downcase.camelize
      begin
        storage_module = Paperclip::Storage.const_get(storage_class_name)
      rescue NameError
        raise Errors::StorageMethodNotFound, "Cannot load storage module '#{storage_class_name}'"
      end
      self.extend(storage_module)
    end

    def assign_attributes
      @queued_for_write[:original] = @file
      assign_file_information
      assign_fingerprint { @file.fingerprint }
      assign_timestamps
    end

    def assign_file_information
      instance_write(:file_name, cleanup_filename(@file.original_filename))
      instance_write(:content_type, @file.content_type.to_s.strip)
      instance_write(:file_size, @file.size)
    end

    def assign_fingerprint
      if instance_respond_to?(:fingerprint)
        instance_write(:fingerprint, yield)
      end
    end

    def assign_timestamps
      if has_enabled_but_unset_created_at?
        instance_write(:created_at, Time.now)
      end

      instance_write(:updated_at, Time.now)
    end

    def post_process_file
      dirty!

      if post_processing
        post_process(*only_process)
      end
    end

    def dirty!
      @dirty = true
    end

    def reset_file_if_original_reprocessed
      instance_write(:file_size, @queued_for_write[:original].size)
      assign_fingerprint { @queued_for_write[:original].fingerprint }
      reset_updater
    end

    def reset_updater
      if instance.respond_to?(updater)
        instance.send(updater)
      end
    end

    def updater
      :"#{name}_file_name_will_change!"
    end

    def extra_options_for(style) #:nodoc:
      process_options(:convert_options, style)
    end

    def extra_source_file_options_for(style) #:nodoc:
      process_options(:source_file_options, style)
    end

    def process_options(options_type, style) #:nodoc:
      all_options   = @options[options_type][:all]
      all_options   = all_options.call(instance)   if all_options.respond_to?(:call)
      style_options = @options[options_type][style]
      style_options = style_options.call(instance) if style_options.respond_to?(:call)

      [ style_options, all_options ].compact.join(" ")
    end

    def post_process(*style_args) #:nodoc:
      return if @queued_for_write[:original].nil?

      instance.run_paperclip_callbacks(:post_process) do
        instance.run_paperclip_callbacks(:"#{name}_post_process") do
          if !@options[:check_validity_before_processing] || !instance.errors.any?
            post_process_styles(*style_args)
          end
        end
      end
    end

    def post_process_styles(*style_args) #:nodoc:
      post_process_style(:original, styles[:original]) if styles.include?(:original) && process_style?(:original, style_args)
      styles.reject{ |name, style| name == :original }.each do |name, style|
        post_process_style(name, style) if process_style?(name, style_args)
      end
    end

    def post_process_style(name, style) #:nodoc:
      begin
        raise RuntimeError.new("Style #{name} has no processors defined.") if style.processors.blank?
        intermediate_files = []
        original = @queued_for_write[:original]

        @queued_for_write[name] = style.processors.
          reduce(original) do |file, processor|
          file = Paperclip.processor(processor).make(file, style.processor_options, self)
          intermediate_files << file unless file == @queued_for_write[:original]
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
    end

    def process_style?(style_name, style_args) #:nodoc:
      style_args.empty? || style_args.include?(style_name)
    end

    def interpolate(pattern, style_name = default_style) #:nodoc:
      interpolator.interpolate(pattern, self, style_name)
    end

    def queue_some_for_delete(*styles)
      @queued_for_delete += styles.uniq.map do |style|
        path(style) if exists?(style)
      end.compact
    end

    def queue_all_for_delete #:nodoc:
      return if !file?
      unless @options[:preserve_files]
        @queued_for_delete += [:original, *styles.keys].uniq.map do |style|
          path(style) if exists?(style)
        end.compact
      end
      instance_write(:file_name, nil)
      instance_write(:content_type, nil)
      instance_write(:file_size, nil)
      instance_write(:fingerprint, nil)
      instance_write(:created_at, nil) if has_enabled_but_unset_created_at?
      instance_write(:updated_at, nil)
    end

    def flush_errors #:nodoc:
      @errors.each do |error, message|
        [message].flatten.each {|m| instance.errors.add(name, m) }
      end
    end

    # called by storage after the writes are flushed and before @queued_for_write is cleared
    def after_flush_writes
      unlink_files(@queued_for_write.values)
    end

    def unlink_files(files)
      Array(files).each do |file|
        file.close unless file.closed?
        file.unlink if file.respond_to?(:unlink) && file.path.present? && File.exist?(file.path)
      end
    end

    # You can either specifiy :restricted_characters or you can define your own
    # :filename_cleaner object. This object needs to respond to #call and takes
    # the filename that will be cleaned. It should return the cleaned filename.
    def filename_cleaner
      @options[:filename_cleaner] || FilenameCleaner.new(@options[:restricted_characters])
    end

    def cleanup_filename(filename)
      filename_cleaner.call(filename)
    end

    # Check if attachment database table has a created_at field
    def able_to_store_created_at?
      @instance.respond_to?("#{name}_created_at".to_sym)
    end

    # Check if attachment database table has a created_at field which is not yet set
    def has_enabled_but_unset_created_at?
      able_to_store_created_at? && !instance_read(:created_at)
    end
  end
end
