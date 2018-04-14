# frozen_string_literal: true
# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Don't forget to edit this file to adapt it to your needs (specially
  # all the grid-related classes)
  #
  # Please note that hints are commented out by default since Foundation
  # doesn't provide styles for hints. You will need to provide your own CSS styles for hints.
  # Uncomment them to enable hints.

  config.wrappers :vertical_form, class: :input, hint_class: :field_with_hint, error_class: :error do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label_input
    b.use :error, wrap_with: { tag: :small, class: :error }

    # b.use :hint,  wrap_with: { tag: :span, class: :hint }
  end

  config.wrappers :horizontal_form, tag: 'div', class: 'row', hint_class: :field_with_hint, error_class: :error do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.wrapper :label_wrapper, tag: :div, class: 'small-3 columns' do |ba|
      ba.use :label, class: 'right inline'
    end

    b.wrapper :right_input_wrapper, tag: :div, class: 'small-9 columns' do |ba|
      ba.use :input
      ba.use :error, wrap_with: { tag: :small, class: :error }
      # ba.use :hint,  wrap_with: { tag: :span, class: :hint }
    end
  end

  config.wrappers :horizontal_radio_and_checkboxes, tag: 'div', class: 'row' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper :container_wrapper, tag: 'div', class: 'small-offset-3 small-9 columns' do |ba|
      ba.wrapper tag: 'label', class: 'checkbox' do |bb|
        bb.use :input
        bb.use :label_text
      end

      ba.use :error, wrap_with: { tag: :small, class: :error }
      # ba.use :hint,  wrap_with: { tag: :span, class: :hint }
    end
  end

  # Foundation does not provide a way to handle inline forms
  # This wrapper can be used to create an inline form
  # by hiding that labels on every screen sizes ('hidden-for-small-up').
  #
  # Note that you need to adapt this wrapper to your needs. If you need a 4
  # columns form then change the wrapper class to 'small-3', if you need
  # only two use 'small-6' and so on.
  config.wrappers :inline_form, tag: 'div', class: 'column small-4', hint_class: :field_with_hint, error_class: :error do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.use :label, class: 'hidden-for-small-up'
    b.use :input

    b.use :error, wrap_with: { tag: :small, class: :error }
    # b.use :hint,  wrap_with: { tag: :span, class: :hint }
  end

  # Examples of use:
  # - wrapper_html: {class: 'row'}, custom_wrapper_html: {class: 'column small-12'}
  # - custom_wrapper_html: {class: 'column small-3 end'}
  config.wrappers :customizable_wrapper, tag: 'div', error_class: :error do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper :custom_wrapper, tag: :div do |ba|
      ba.use :label_input
    end

    b.use :error, wrap_with: { tag: :small, class: :error }
    # b.use :hint,  wrap_with: { tag: :span, class: :hint }
  end

  # CSS class for buttons
  config.button_class = 'button'

  # Set this to div to make the checkbox and radio properly work
  # otherwise simple_form adds a label tag instead of a div around
  # the nested label
  config.item_wrapper_tag = :div

  # CSS class to add for error notification helper.
  config.error_notification_class = 'alert-box alert'

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :vertical_form
end
