require 'encryptor'

# Adds attr_accessors that encrypt and decrypt an object's attributes
module AttrEncrypted
  autoload :Version, 'attr_encrypted/version'

  def self.extended(base) # :nodoc:
    base.class_eval do
      include InstanceMethods
      attr_writer :attr_encrypted_options
      @attr_encrypted_options, @encrypted_attributes = {}, {}
    end
  end

  # Generates attr_accessors that encrypt and decrypt attributes transparently
  #
  # Options (any other options you specify are passed to the Encryptor's encrypt and decrypt methods)
  #
  #   attribute:            The name of the referenced encrypted attribute. For example
  #                         <tt>attr_accessor :email, attribute: :ee</tt> would generate an
  #                         attribute named 'ee' to store the encrypted email. This is useful when defining
  #                         one attribute to encrypt at a time or when the :prefix and :suffix options
  #                         aren't enough.
  #                         Defaults to nil.
  #
  #   prefix:               A prefix used to generate the name of the referenced encrypted attributes.
  #                         For example <tt>attr_accessor :email, prefix: 'crypted_'</tt> would
  #                         generate attributes named 'crypted_email' to store the encrypted
  #                         email and password.
  #                         Defaults to 'encrypted_'.
  #
  #   suffix:               A suffix used to generate the name of the referenced encrypted attributes.
  #                         For example <tt>attr_accessor :email, prefix: '', suffix: '_encrypted'</tt>
  #                         would generate attributes named 'email_encrypted' to store the
  #                         encrypted email.
  #                         Defaults to ''.
  #
  #   key:                  The encryption key. This option may not be required if
  #                         you're using a custom encryptor. If you pass a symbol
  #                         representing an instance method then the :key option
  #                         will be replaced with the result of the method before
  #                         being passed to the encryptor. Objects that respond
  #                         to :call are evaluated as well (including procs).
  #                         Any other key types will be passed directly to the encryptor.
  #                         Defaults to nil.
  #
  #   encode:               If set to true, attributes will be encoded as well as
  #                         encrypted. This is useful if you're planning on storing
  #                         the encrypted attributes in a database. The default
  #                         encoding is 'm' (base64), however this can be overwritten
  #                         by setting the :encode option to some other encoding
  #                         string instead of just 'true'. See
  #                         http://www.ruby-doc.org/core/classes/Array.html#M002245
  #                         for more encoding directives.
  #                         Defaults to false unless you're using it with ActiveRecord, DataMapper, or Sequel.
  #
  #   encode_iv:            Defaults to true.

  #   encode_salt:          Defaults to true.
  #
  #   default_encoding:     Defaults to 'm' (base64).
  #
  #   marshal:              If set to true, attributes will be marshaled as well
  #                         as encrypted. This is useful if you're planning on
  #                         encrypting something other than a string.
  #                         Defaults to false.
  #
  #   marshaler:            The object to use for marshaling.
  #                         Defaults to Marshal.
  #
  #   dump_method:          The dump method name to call on the <tt>:marshaler</tt> object to.
  #                         Defaults to 'dump'.
  #
  #   load_method:          The load method name to call on the <tt>:marshaler</tt> object.
  #                         Defaults to 'load'.
  #
  #   encryptor:            The object to use for encrypting.
  #                         Defaults to Encryptor.
  #
  #   encrypt_method:       The encrypt method name to call on the <tt>:encryptor</tt> object.
  #                         Defaults to 'encrypt'.
  #
  #   decrypt_method:       The decrypt method name to call on the <tt>:encryptor</tt> object.
  #                         Defaults to 'decrypt'.
  #
  #   if:                   Attributes are only encrypted if this option evaluates
  #                         to true. If you pass a symbol representing an instance
  #                         method then the result of the method will be evaluated.
  #                         Any objects that respond to <tt>:call</tt> are evaluated as well.
  #                         Defaults to true.
  #
  #   unless:               Attributes are only encrypted if this option evaluates
  #                         to false. If you pass a symbol representing an instance
  #                         method then the result of the method will be evaluated.
  #                         Any objects that respond to <tt>:call</tt> are evaluated as well.
  #                         Defaults to false.
  #
  #   mode:                 Selects encryption mode for attribute: choose <tt>:single_iv_and_salt</tt> for compatibility
  #                         with the old attr_encrypted API: the IV is derived from the encryption key by the underlying Encryptor class; salt is not used.
  #                         The <tt>:per_attribute_iv_and_salt</tt> mode uses a per-attribute IV and salt. The salt is used to derive a unique key per attribute.
  #                         A <tt>:per_attribute_iv</default> mode derives a unique IV per attribute; salt is not used.
  #                         Defaults to <tt>:per_attribute_iv</tt>.
  #
  #   allow_empty_value:    Attributes which have nil or empty string values will not be encrypted unless this option
  #                         has a truthy value.
  #
  # You can specify your own default options
  #
  #   class User
  #     # Now all attributes will be encoded and marshaled by default
  #     attr_encrypted_options.merge!(encode: true, marshal: true, some_other_option: true)
  #     attr_encrypted :configuration, key: 'my secret key'
  #   end
  #
  #
  # Example
  #
  #   class User
  #     attr_encrypted :email, key: 'some secret key'
  #     attr_encrypted :configuration, key: 'some other secret key', marshal: true
  #   end
  #
  #   @user = User.new
  #   @user.encrypted_email # nil
  #   @user.email? # false
  #   @user.email = 'test@example.com'
  #   @user.email? # true
  #   @user.encrypted_email # returns the encrypted version of 'test@example.com'
  #
  #   @user.configuration = { time_zone: 'UTC' }
  #   @user.encrypted_configuration # returns the encrypted version of configuration
  #
  #   See README for more examples
  def attr_encrypted(*attributes)
    options = attributes.last.is_a?(Hash) ? attributes.pop : {}
    options = attr_encrypted_default_options.dup.merge!(attr_encrypted_options).merge!(options)

    options[:encode] = options[:default_encoding] if options[:encode] == true
    options[:encode_iv] = options[:default_encoding] if options[:encode_iv] == true
    options[:encode_salt] = options[:default_encoding] if options[:encode_salt] == true

    attributes.each do |attribute|
      encrypted_attribute_name = (options[:attribute] ? options[:attribute] : [options[:prefix], attribute, options[:suffix]].join).to_sym

      instance_methods_as_symbols = attribute_instance_methods_as_symbols

      if attribute_instance_methods_as_symbols_available?
        attr_reader encrypted_attribute_name unless instance_methods_as_symbols.include?(encrypted_attribute_name)
        attr_writer encrypted_attribute_name unless instance_methods_as_symbols.include?(:"#{encrypted_attribute_name}=")

        iv_name = "#{encrypted_attribute_name}_iv".to_sym
        attr_reader iv_name unless instance_methods_as_symbols.include?(iv_name)
        attr_writer iv_name unless instance_methods_as_symbols.include?(:"#{iv_name}=")

        salt_name = "#{encrypted_attribute_name}_salt".to_sym
        attr_reader salt_name unless instance_methods_as_symbols.include?(salt_name)
        attr_writer salt_name unless instance_methods_as_symbols.include?(:"#{salt_name}=")
      end

      define_method(attribute) do
        instance_variable_get("@#{attribute}") || instance_variable_set("@#{attribute}", decrypt(attribute, send(encrypted_attribute_name)))
      end

      define_method("#{attribute}=") do |value|
        send("#{encrypted_attribute_name}=", encrypt(attribute, value))
        instance_variable_set("@#{attribute}", value)
      end

      define_method("#{attribute}?") do
        value = send(attribute)
        value.respond_to?(:empty?) ? !value.empty? : !!value
      end

      encrypted_attributes[attribute.to_sym] = options.merge(attribute: encrypted_attribute_name)
    end
  end

  alias_method :attr_encryptor, :attr_encrypted

  # Default options to use with calls to <tt>attr_encrypted</tt>
  #
  # It will inherit existing options from its superclass
  def attr_encrypted_options
    @attr_encrypted_options ||= superclass.attr_encrypted_options.dup
  end

  def attr_encrypted_default_options
    {
      prefix:            'encrypted_',
      suffix:            '',
      if:                true,
      unless:            false,
      encode:            false,
      encode_iv:         true,
      encode_salt:       true,
      default_encoding:  'm',
      marshal:           false,
      marshaler:         Marshal,
      dump_method:       'dump',
      load_method:       'load',
      encryptor:         Encryptor,
      encrypt_method:    'encrypt',
      decrypt_method:    'decrypt',
      mode:              :per_attribute_iv,
      algorithm:         'aes-256-gcm',
      allow_empty_value: false,
    }
  end

  private :attr_encrypted_default_options

  # Checks if an attribute is configured with <tt>attr_encrypted</tt>
  #
  # Example
  #
  #   class User
  #     attr_accessor :name
  #     attr_encrypted :email
  #   end
  #
  #   User.attr_encrypted?(:name)  # false
  #   User.attr_encrypted?(:email) # true
  def attr_encrypted?(attribute)
    encrypted_attributes.has_key?(attribute.to_sym)
  end

  # Decrypts a value for the attribute specified
  #
  # Example
  #
  #   class User
  #     attr_encrypted :email
  #   end
  #
  #   email = User.decrypt(:email, 'SOME_ENCRYPTED_EMAIL_STRING')
  def decrypt(attribute, encrypted_value, options = {})
    options = encrypted_attributes[attribute.to_sym].merge(options)
    if options[:if] && !options[:unless] && not_empty?(encrypted_value)
      encrypted_value = encrypted_value.unpack(options[:encode]).first if options[:encode]
      value = options[:encryptor].send(options[:decrypt_method], options.merge!(value: encrypted_value))
      if options[:marshal]
        value = options[:marshaler].send(options[:load_method], value)
      elsif defined?(Encoding)
        encoding = Encoding.default_internal || Encoding.default_external
        value = value.force_encoding(encoding.name)
      end
      value
    else
      encrypted_value
    end
  end

  # Encrypts a value for the attribute specified
  #
  # Example
  #
  #   class User
  #     attr_encrypted :email
  #   end
  #
  #   encrypted_email = User.encrypt(:email, 'test@example.com')
  def encrypt(attribute, value, options = {})
    options = encrypted_attributes[attribute.to_sym].merge(options)
    if options[:if] && !options[:unless] && (options[:allow_empty_value] || not_empty?(value))
      value = options[:marshal] ? options[:marshaler].send(options[:dump_method], value) : value.to_s
      encrypted_value = options[:encryptor].send(options[:encrypt_method], options.merge!(value: value))
      encrypted_value = [encrypted_value].pack(options[:encode]) if options[:encode]
      encrypted_value
    else
      value
    end
  end

  def not_empty?(value)
    !value.nil? && !(value.is_a?(String) && value.empty?)
  end

  # Contains a hash of encrypted attributes with virtual attribute names as keys
  # and their corresponding options as values
  #
  # Example
  #
  #   class User
  #     attr_encrypted :email, key: 'my secret key'
  #   end
  #
  #   User.encrypted_attributes # { email: { attribute: 'encrypted_email', key: 'my secret key' } }
  def encrypted_attributes
    @encrypted_attributes ||= superclass.encrypted_attributes.dup
  end

  # Forwards calls to :encrypt_#{attribute} or :decrypt_#{attribute} to the corresponding encrypt or decrypt method
  # if attribute was configured with attr_encrypted
  #
  # Example
  #
  #   class User
  #     attr_encrypted :email, key: 'my secret key'
  #   end
  #
  #   User.encrypt_email('SOME_ENCRYPTED_EMAIL_STRING')
  def method_missing(method, *arguments, &block)
    if method.to_s =~ /^((en|de)crypt)_(.+)$/ && attr_encrypted?($3)
      send($1, $3, *arguments)
    else
      super
    end
  end

  module InstanceMethods
    # Decrypts a value for the attribute specified using options evaluated in the current object's scope
    #
    # Example
    #
    #  class User
    #    attr_accessor :secret_key
    #    attr_encrypted :email, key: :secret_key
    #
    #    def initialize(secret_key)
    #      self.secret_key = secret_key
    #    end
    #  end
    #
    #  @user = User.new('some-secret-key')
    #  @user.decrypt(:email, 'SOME_ENCRYPTED_EMAIL_STRING')
    def decrypt(attribute, encrypted_value)
      encrypted_attributes[attribute.to_sym][:operation] = :decrypting
      encrypted_attributes[attribute.to_sym][:value_present] = self.class.not_empty?(encrypted_value)
      self.class.decrypt(attribute, encrypted_value, evaluated_attr_encrypted_options_for(attribute))
    end

    # Encrypts a value for the attribute specified using options evaluated in the current object's scope
    #
    # Example
    #
    #  class User
    #    attr_accessor :secret_key
    #    attr_encrypted :email, key: :secret_key
    #
    #    def initialize(secret_key)
    #      self.secret_key = secret_key
    #    end
    #  end
    #
    #  @user = User.new('some-secret-key')
    #  @user.encrypt(:email, 'test@example.com')
    def encrypt(attribute, value)
      encrypted_attributes[attribute.to_sym][:operation] = :encrypting
      encrypted_attributes[attribute.to_sym][:value_present] = self.class.not_empty?(value)
      self.class.encrypt(attribute, value, evaluated_attr_encrypted_options_for(attribute))
    end

    # Copies the class level hash of encrypted attributes with virtual attribute names as keys
    # and their corresponding options as values to the instance
    #
    def encrypted_attributes
      @encrypted_attributes ||= self.class.encrypted_attributes.dup
    end

    protected

      # Returns attr_encrypted options evaluated in the current object's scope for the attribute specified
      def evaluated_attr_encrypted_options_for(attribute)
        evaluated_options = Hash.new
        attribute_option_value = encrypted_attributes[attribute.to_sym][:attribute]
        encrypted_attributes[attribute.to_sym].map do |option, value|
          evaluated_options[option] = evaluate_attr_encrypted_option(value)
        end

        evaluated_options[:attribute] = attribute_option_value

        evaluated_options.tap do |options|
          if options[:if] && !options[:unless] && options[:value_present] || options[:allow_empty_value]
            unless options[:mode] == :single_iv_and_salt
              load_iv_for_attribute(attribute, options)
            end

            if options[:mode] == :per_attribute_iv_and_salt
              load_salt_for_attribute(attribute, options)
            end
          end
        end
      end

      # Evaluates symbol (method reference) or proc (responds to call) options
      #
      # If the option is not a symbol or proc then the original option is returned
      def evaluate_attr_encrypted_option(option)
        if option.is_a?(Symbol) && respond_to?(option, true)
          send(option)
        elsif option.respond_to?(:call)
          option.call(self)
        else
          option
        end
      end

      def load_iv_for_attribute(attribute, options)
        encrypted_attribute_name = options[:attribute]
        encode_iv = options[:encode_iv]
        iv = options[:iv] || send("#{encrypted_attribute_name}_iv")
        if options[:operation] == :encrypting
          begin
            iv = generate_iv(options[:algorithm])
            iv = [iv].pack(encode_iv) if encode_iv
            send("#{encrypted_attribute_name}_iv=", iv)
          rescue RuntimeError
          end
        end
        if iv && !iv.empty?
          iv = iv.unpack(encode_iv).first if encode_iv
          options[:iv] = iv
        end
      end

      def generate_iv(algorithm)
        algo = OpenSSL::Cipher.new(algorithm)
        algo.encrypt
        algo.random_iv
      end

      def load_salt_for_attribute(attribute, options)
        encrypted_attribute_name = options[:attribute]
        encode_salt = options[:encode_salt]
        salt = options[:salt] || send("#{encrypted_attribute_name}_salt")
        if options[:operation] == :encrypting
          salt = SecureRandom.random_bytes
          salt = prefix_and_encode_salt(salt, encode_salt) if encode_salt
          send("#{encrypted_attribute_name}_salt=", salt)
        end
        if salt && !salt.empty?
          salt = decode_salt_if_encoded(salt, encode_salt) if encode_salt
          options[:salt] = salt
        end
      end

      def prefix_and_encode_salt(salt, encoding)
        prefix = '_'
        prefix + [salt].pack(encoding)
      end

      def decode_salt_if_encoded(salt, encoding)
        prefix = '_'
        salt.slice(0).eql?(prefix) ? salt.slice(1..-1).unpack(encoding).first : salt
      end
  end

  protected

  def attribute_instance_methods_as_symbols
    instance_methods.collect { |method| method.to_sym }
  end

  def attribute_instance_methods_as_symbols_available?
    true
  end

end


Dir[File.join(File.dirname(__FILE__), 'attr_encrypted', 'adapters', '*.rb')].each { |adapter| require adapter }
