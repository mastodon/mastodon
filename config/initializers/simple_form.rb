# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.

module AppendComponent
  def append(_wrapper_options = nil)
    @append ||= begin
      options[:append].to_s.html_safe if options[:append].present?
    end
  end
end

module RecommendedComponent
  def recommended(_wrapper_options = nil)
    return unless options[:recommended]

    key = options[:recommended].is_a?(Symbol) ? options[:recommended] : :recommended
    options[:label_text] = ->(raw_label_text, _required_label_text, _label_present) { safe_join([raw_label_text, ' ', content_tag(:span, I18n.t(key, scope: 'simple_form'), class: key)]) }

    nil
  end
end

module WarningHintComponent
  def warning_hint(_wrapper_options = nil)
    @warning_hint ||= begin
      options[:warning_hint].to_s.html_safe if options[:warning_hint].present?
    end
  end
end

module GlitchOnlyComponent
  def glitch_only(_wrapper_options = nil)
    return unless options[:glitch_only]

    options[:label_text] = ->(raw_label_text, _required_label_text, _label_present) { safe_join([raw_label_text, ' ', content_tag(:span, I18n.t('simple_form.glitch_only'), class: 'glitch_only')]) }
    nil
  end
end

SimpleForm.include_component(AppendComponent)
SimpleForm.include_component(RecommendedComponent)
SimpleForm.include_component(WarningHintComponent)
SimpleForm.include_component(GlitchOnlyComponent)

SimpleForm.setup do |config|
  # Wrappers are used by the form builder to generate a
  # complete input. You can remove any component from the
  # wrapper, change the order or even add your own to the
  # stack. The options given below are used to wrap the
  # whole input.
  config.wrappers :default, class: :input, hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    ## Extensions enabled by default
    # Any of these extensions can be disabled for a
    # given input by passing: `f.input EXTENSION_NAME => false`.
    # You can make any of these extensions optional by
    # renaming `b.use` to `b.optional`.

    # Determines whether to use HTML5 (:email, :url, ...)
    # and required attributes
    b.use :html5

    # Calculates placeholders automatically from I18n
    # You can also pass a string as f.input placeholder: "Placeholder"
    b.use :placeholder

    ## Optional extensions
    # They are disabled unless you pass `f.input EXTENSION_NAME => true`
    # to the input. If so, they will retrieve the values from the model
    # if any exists. If you want to enable any of those
    # extensions by default, you can change `b.optional` to `b.use`.

    # Calculates maxlength from length validations for string inputs
    b.optional :maxlength

    # Calculates pattern from format validations for string inputs
    b.optional :pattern

    # Calculates min and max from length validations for numeric inputs
    b.optional :min_max

    # Calculates readonly automatically from readonly attributes
    b.optional :readonly

    ## Inputs
    b.use :input
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
    b.use :error, wrap_with: { tag: :span, class: :error }

    ## full_messages_for
    # If you want to display the full error message for the attribute, you can
    # use the component :full_error, like:
    #
    # b.use :full_error, wrap_with: { tag: :span, class: :error }
  end

  config.wrappers :with_label, class: [:input, :with_label], hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    b.use :html5

    b.wrapper tag: :div, class: :label_input do |ba|
      ba.optional :recommended
      ba.optional :glitch_only
      ba.use :label

      ba.wrapper tag: :div, class: :label_input__wrapper do |bb|
        bb.use :input
        bb.optional :append, wrap_with: { tag: :div, class: 'label_input__append' }
      end
    end

    b.use :warning_hint, wrap_with: { tag: :span, class: [:hint, 'warning-hint'] }
    b.use :hint, wrap_with: { tag: :span, class: :hint }
    b.use :error, wrap_with: { tag: :span, class: :error }
  end

  config.wrappers :with_floating_label, class: [:input, :with_floating_label], hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    b.use :html5
    b.use :label_input, wrap_with: { tag: :div, class: :label_input }
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
    b.use :error, wrap_with: { tag: :span, class: :error }
  end

  config.wrappers :with_block_label, class: [:input, :with_block_label], hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    b.use :html5
    b.use :label
    b.use :warning_hint, wrap_with: { tag: :span, class: [:hint, 'warning-hint'] }
    b.use :hint, wrap_with: { tag: :span, class: :hint }
    b.use :input, wrap_with: { tag: :div, class: :label_input }
    b.use :error, wrap_with: { tag: :span, class: :error }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :default

  # Define the way to render check boxes / radio buttons with labels.
  # Defaults to :nested for bootstrap config.
  #   inline: input + label
  #   nested: label > input
  config.boolean_style = :nested

  # Default class for buttons
  config.button_class = 'btn'

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # Use :to_sentence to list all errors for each field.
  # config.error_method = :first

  # Default tag used for error notification helper.
  config.error_notification_tag = :div

  # CSS class to add for error notification helper.
  config.error_notification_class = 'error_notification'

  # ID to add for error notification helper.
  # config.error_notification_id = nil

  # Series of attempts to detect a default label method for collection.
  # config.collection_label_methods = [ :to_label, :name, :title, :to_s ]

  # Series of attempts to detect a default value method for collection.
  # config.collection_value_methods = [ :id, :to_s ]

  # You can wrap a collection of radio/check boxes in a pre-defined tag, defaulting to none.
  # config.collection_wrapper_tag = nil

  # You can define the class to use on all collection wrappers. Defaulting to none.
  # config.collection_wrapper_class = nil

  # You can wrap each item in a collection of radio/check boxes with a tag,
  # defaulting to :span.
  # config.item_wrapper_tag = :span

  # You can define a class to use in all item wrappers. Defaulting to none.
  # config.item_wrapper_class = nil

  # How the label text should be generated altogether with the required text.
  config.label_text = lambda { |label, required, explicit_label| "#{label} #{required}" }

  # You can define the class to use on all labels. Default is nil.
  # config.label_class = nil

  # You can define the default class to be used on forms. Can be overridden
  # with `html: { :class }`. Defaulting to none.
  # config.default_form_class = nil

  # You can define which elements should obtain additional classes
  # config.generate_additional_classes_for = [:wrapper, :label, :input]

  # Whether attributes are required by default (or not). Default is true.
  # config.required_by_default = true

  # Tell browsers whether to use the native HTML5 validations (novalidate form option).
  # These validations are enabled in SimpleForm's internal config but disabled by default
  # in this configuration, which is recommended due to some quirks from different browsers.
  # To stop SimpleForm from generating the novalidate option, enabling the HTML5 validations,
  # change this configuration to true.
  config.browser_validations = false

  # Collection of methods to detect if a file type was given.
  # config.file_methods = [ :mounted_as, :file?, :public_filename ]

  # Custom mappings for input types. This should be a hash containing a regexp
  # to match as key, and the input type that will be used when the field name
  # matches the regexp as value.
  # config.input_mappings = { /count/ => :integer }

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper that will be used for all inputs with specified type.
  # config.wrapper_mappings = { string: :prepend }

  # Namespaces where SimpleForm should look for custom input classes that
  # override default inputs.
  # config.custom_inputs_namespaces << "CustomInputs"

  # Default priority for time_zone inputs.
  # config.time_zone_priority = nil

  # Default priority for country inputs.
  # config.country_priority = nil

  # When false, do not use translations for labels.
  # config.translate_labels = true

  # Automatically discover new inputs in Rails' autoload path.
  # config.inputs_discovery = true

  # Cache SimpleForm inputs discovery
  # config.cache_discovery = !Rails.env.development?

  # Default class for inputs
  # config.input_class = nil

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = 'checkbox'

  # Defines if the default input wrapper class should be included in radio
  # collection wrappers.
  # config.include_default_input_wrapper_class = true

  # Defines which i18n scope will be used in Simple Form.
  # config.i18n_scope = 'simple_form'
end
