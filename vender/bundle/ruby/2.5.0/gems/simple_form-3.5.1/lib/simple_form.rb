# frozen_string_literal: true
require 'action_view'
require 'action_pack'
require 'simple_form/action_view_extensions/form_helper'
require 'simple_form/action_view_extensions/builder'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/reverse_merge'

module SimpleForm
  extend ActiveSupport::Autoload

  autoload :Helpers
  autoload :Wrappers

  eager_autoload do
    autoload :Components
    autoload :ErrorNotification
    autoload :FormBuilder
    autoload :Inputs
  end

  def self.eager_load!
    super
    SimpleForm::Inputs.eager_load!
    SimpleForm::Components.eager_load!
  end

  CUSTOM_INPUT_DEPRECATION_WARN = <<-WARN
%{name} method now accepts a `wrapper_options` argument. The method definition without the argument is deprecated and will be removed in the next Simple Form version. Change your code from:

    def %{name}

to

    def %{name}(wrapper_options)

See https://github.com/plataformatec/simple_form/pull/997 for more information.
  WARN

  @@configured = false

  def self.configured? #:nodoc:
    @@configured
  end

  ## CONFIGURATION OPTIONS

  # Method used to tidy up errors.
  mattr_accessor :error_method
  @@error_method = :first

  # Default tag used for error notification helper.
  mattr_accessor :error_notification_tag
  @@error_notification_tag = :p

  # CSS class to add for error notification helper.
  mattr_accessor :error_notification_class
  @@error_notification_class = :error_notification

  # Series of attemps to detect a default label method for collection.
  mattr_accessor :collection_label_methods
  @@collection_label_methods = %i[to_label name title to_s]

  # Series of attemps to detect a default value method for collection.
  mattr_accessor :collection_value_methods
  @@collection_value_methods = %i[id to_s]

  # You can wrap a collection of radio/check boxes in a pre-defined tag, defaulting to none.
  mattr_accessor :collection_wrapper_tag
  @@collection_wrapper_tag = nil

  # You can define the class to use on all collection wrappers, defaulting to none.
  mattr_accessor :collection_wrapper_class
  @@collection_wrapper_class = nil

  # You can wrap each item in a collection of radio/check boxes with a tag,
  # defaulting to span. Please note that when using :boolean_style = :nested,
  # SimpleForm will force this option to be a :label.
  mattr_accessor :item_wrapper_tag
  @@item_wrapper_tag = :span

  # You can define the class to use on all item wrappers, defaulting to none.
  mattr_accessor :item_wrapper_class
  @@item_wrapper_class = nil

  # How the label text should be generated altogether with the required text.
  mattr_accessor :label_text
  @@label_text = ->(label, required, explicit_label) { "#{required} #{label}" }

  # You can define the class to be used on all labels. Defaults to none.
  mattr_accessor :label_class
  @@label_class = nil

  # Define the way to render check boxes / radio buttons with labels.
  #   inline: input + label (default)
  #   nested: label > input
  mattr_accessor :boolean_style
  @@boolean_style = :inline

  # DEPRECATED: You can define the class to be used on all forms. Default is
  # simple_form.
  mattr_reader :form_class
  @@form_class = :simple_form

  # You can define the default class to be used on all forms. Can be overriden
  # with `html: { :class }`. Defaults to none.
  mattr_accessor :default_form_class
  @@default_form_class = nil

  # You can define which elements should obtain additional classes.
  mattr_accessor :generate_additional_classes_for
  @@generate_additional_classes_for = %i[wrapper label input]

  # Whether attributes are required by default or not.
  mattr_accessor :required_by_default
  @@required_by_default = true

  # Tell browsers whether to use default HTML5 validations (novalidate option).
  mattr_accessor :browser_validations
  @@browser_validations = true

  # Collection of methods to detect if a file type was given.
  mattr_accessor :file_methods
  @@file_methods = %i[mounted_as file? public_filename]

  # Custom mappings for input types. This should be a hash containing a regexp
  # to match as key, and the input type that will be used when the field name
  # matches the regexp as value, such as { /count/ => :integer }.
  mattr_accessor :input_mappings
  @@input_mappings = nil

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper that will be used for all inputs with specified type.
  # e.g { string: :string_wrapper, boolean: :boolean_wrapper }
  # You can also set a wrapper mapping per form basis.
  # e.g simple_form_for(@foo, wrapper_mappings: { check_boxes: :bootstrap_checkbox })
  mattr_accessor :wrapper_mappings
  @@wrapper_mappings = nil

  # Namespaces where SimpleForm should look for custom input classes that override
  # default inputs. Namespaces are given as string to allow lazy loading inputs.
  # e.g. config.custom_inputs_namespaces << "CustomInputs"
  #      will try to find CustomInputs::NumericInput when an :integer
  #      field is called.
  mattr_accessor :custom_inputs_namespaces
  @@custom_inputs_namespaces = []

  # Default priority for time_zone inputs.
  mattr_accessor :time_zone_priority
  @@time_zone_priority = nil

  # Default priority for country inputs.
  mattr_accessor :country_priority
  @@country_priority = nil

  # When off, do not use translations in labels. Disabling translation in
  # hints and placeholders can be done manually in the wrapper API.
  mattr_accessor :translate_labels
  @@translate_labels = true

  # Automatically discover new inputs in Rails' autoload path.
  mattr_accessor :inputs_discovery
  @@inputs_discovery = true

  # Cache SimpleForm inputs discovery.
  mattr_accessor :cache_discovery
  @@cache_discovery = defined?(Rails.env) && !Rails.env.development?

  # Adds a class to each generated button, mostly for compatiblity.
  mattr_accessor :button_class
  @@button_class = 'button'

  # Override the default ActiveModelHelper behaviour of wrapping the input.
  # This gets taken care of semantically by adding an error class to the wrapper tag
  # containing the input.
  mattr_accessor :field_error_proc
  @@field_error_proc = proc do |html_tag, instance_tag|
    html_tag
  end

  # Adds a class to each generated inputs
  mattr_accessor :input_class
  @@input_class = nil

  # Defines if an input wrapper class should be included or not
  mattr_accessor :include_default_input_wrapper_class
  @@include_default_input_wrapper_class = true

  # Define the default class of the input wrapper of the boolean input.
  mattr_accessor :boolean_label_class
  @@boolean_label_class = 'checkbox'

  ## WRAPPER CONFIGURATION
  # The default wrapper to be used by the FormBuilder.
  mattr_accessor :default_wrapper
  @@default_wrapper = :default
  @@wrappers = {} #:nodoc:

  mattr_accessor :i18n_scope
  @@i18n_scope = 'simple_form'

  # Retrieves a given wrapper
  def self.wrapper(name)
    @@wrappers[name.to_s] or raise WrapperNotFound, "Couldn't find wrapper with name #{name}"
  end

  # Raised when fails to find a given wrapper name
  class WrapperNotFound < StandardError
  end

  # Define a new wrapper using SimpleForm::Wrappers::Builder
  # and store it in the given name.
  def self.wrappers(*args, &block)
    if block_given?
      options                 = args.extract_options!
      name                    = args.first || :default
      @@wrappers[name.to_s]   = build(options, &block)
    else
      @@wrappers
    end
  end

  # Builds a new wrapper using SimpleForm::Wrappers::Builder.
  def self.build(options = {})
    options[:tag] = :div if options[:tag].nil?
    builder = SimpleForm::Wrappers::Builder.new(options)
    yield builder
    SimpleForm::Wrappers::Root.new(builder.to_a, options)
  end

  wrappers class: :input, hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    b.use :html5

    b.use :min_max
    b.use :maxlength
    b.use :minlength
    b.use :placeholder
    b.optional :pattern
    b.optional :readonly

    b.use :label_input
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
    b.use :error, wrap_with: { tag: :span, class: :error }
  end

  def self.additional_classes_for(component)
    generate_additional_classes_for.include?(component) ? yield : []
  end

  ## SETUP

  def self.default_input_size=(*)
    ActiveSupport::Deprecation.warn "[SIMPLE_FORM] SimpleForm.default_input_size= is deprecated and has no effect", caller
  end

  def self.form_class=(value)
    ActiveSupport::Deprecation.warn "[SIMPLE_FORM] SimpleForm.form_class= is deprecated and will be removed in 4.x. Use SimpleForm.default_form_class= instead", caller
    @@form_class = value
  end

  # Default way to setup Simple Form. Run rails generate simple_form:install
  # to create a fresh initializer with all configuration values.
  def self.setup
    @@configured = true
    yield self
  end
end

require 'simple_form/railtie' if defined?(Rails)
