# frozen_string_literal: true
module MiscHelpers
  def store_translations(locale, translations, &block)
    I18n.backend.store_translations locale, translations
    yield
  ensure
    I18n.reload!
    I18n.backend.send :init_translations
  end

  def assert_no_select(selector, value = nil)
    assert_select(selector, text: value, count: 0)
  end

  def swap(object, new_values)
    old_values = {}
    new_values.each do |key, value|
      old_values[key] = object.send key
      object.send :"#{key}=", value
    end
    yield
  ensure
    old_values.each do |key, value|
      object.send :"#{key}=", value
    end
  end

  def stub_any_instance(klass, method, value)
    klass.class_eval do
      alias_method :"new_#{method}", method

      define_method(method) do
        if value.respond_to?(:call)
          value.call
        else
          value
        end
      end
    end

    yield
  ensure
    klass.class_eval do
      undef_method method
      alias_method method, :"new_#{method}"
      undef_method :"new_#{method}"
    end
  end

  def swap_wrapper(name = :default, wrapper = custom_wrapper)
    old = SimpleForm.wrappers[name.to_s]
    SimpleForm.wrappers[name.to_s] = wrapper
    yield
  ensure
    SimpleForm.wrappers[name.to_s] = old
  end

  def custom_wrapper
    SimpleForm.build tag: :section, class: "custom_wrapper", pattern: false do |b|
      b.use :pattern
      b.wrapper :another, class: "another_wrapper" do |ba|
        ba.use :label
        ba.use :input
      end
      b.wrapper :error_wrapper, tag: :div, class: "error_wrapper" do |be|
        be.use :error, wrap_with: { tag: :span, class: "omg_error" }
      end
      b.use :hint, wrap_with: { class: "omg_hint" }
    end
  end

  def custom_wrapper_with_wrapped_optional_component
    SimpleForm.build tag: :section, class: "custom_wrapper" do |b|
      b.wrapper tag: :div, class: 'no_output_wrapper' do |ba|
        ba.optional :hint, wrap_with: { tag: :p, class: 'omg_hint' }
      end
    end
  end

  def custom_wrapper_with_unless_blank
    SimpleForm.build tag: :section, class: "custom_wrapper" do |b|
      b.wrapper tag: :div, class: 'no_output_wrapper', unless_blank: true do |ba|
        ba.optional :hint, wrap_with: { tag: :p, class: 'omg_hint' }
      end
    end
  end

  def custom_wrapper_with_input_class
    SimpleForm.build tag: :div, class: "custom_wrapper" do |b|
      b.use :label
      b.use :input, class: 'inline-class'
    end
  end

  def custom_wrapper_with_input_data_modal
    SimpleForm.build tag: :div, class: "custom_wrapper" do |b|
      b.use :label
      b.use :input, data: { modal: 'data-modal', wrapper: 'data-wrapper' }
    end
  end

  def custom_wrapper_with_input_aria_modal
    SimpleForm.build tag: :div, class: "custom_wrapper" do |b|
      b.use :label
      b.use :input, aria: { modal: 'aria-modal', wrapper: 'aria-wrapper' }
    end
  end

  def custom_wrapper_with_label_class
    SimpleForm.build tag: :div, class: "custom_wrapper" do |b|
      b.use :label, class: 'inline-class'
      b.use :input
    end
  end

  def custom_wrapper_with_input_attributes
    SimpleForm.build tag: :div, class: "custom_wrapper" do |b|
      b.use :input, data: { modal: true }
    end
  end

  def custom_wrapper_with_label_input_class
    SimpleForm.build tag: :div, class: "custom_wrapper" do |b|
      b.use :label_input, class: 'inline-class'
    end
  end

  def custom_wrapper_with_wrapped_input
    SimpleForm.build tag: :div, class: "custom_wrapper" do |b|
      b.wrapper tag: :div, class: 'elem' do |component|
        component.use :label
        component.use :input, wrap_with: { tag: :div, class: 'input' }
      end
    end
  end

  def custom_wrapper_with_wrapped_label
    SimpleForm.build tag: :div, class: "custom_wrapper" do |b|
      b.wrapper tag: :div, class: 'elem' do |component|
        component.use :label, wrap_with: { tag: :div, class: 'label' }
        component.use :input
      end
    end
  end

  def custom_wrapper_without_top_level
    SimpleForm.build tag: false, class: 'custom_wrapper_without_top_level' do |b|
      b.use :label_input
      b.use :hint,  wrap_with: { tag: :span, class: :hint }
      b.use :error, wrap_with: { tag: :span, class: :error }
    end
  end

  def custom_wrapper_without_class
    SimpleForm.build tag: :div, wrapper_html: { id: 'custom_wrapper_without_class' } do |b|
      b.use :label_input
    end
  end

  def custom_wrapper_with_label_html_option
    SimpleForm.build tag: :div, class: "custom_wrapper", label_html: { class: 'extra-label-class' } do |b|
      b.use :label_input
    end
  end

  def custom_wrapper_with_wrapped_label_input
    SimpleForm.build tag: :section, class: "custom_wrapper", pattern: false do |b|
      b.use :label_input, wrap_with: { tag: :div, class: :field }
    end
  end

  def custom_wrapper_with_additional_attributes
    SimpleForm.build tag: :div, class: 'custom_wrapper', html: { data: { wrapper: :test }, title: 'some title' } do |b|
      b.use :label_input
    end
  end

  def custom_wrapper_with_full_error
    SimpleForm.build tag: :div, class: 'custom_wrapper' do |b|
      b.use :full_error,  wrap_with: { tag: :span, class: :error }
    end
  end

  def custom_wrapper_with_label_text
    SimpleForm.build label_text: proc { |label, required| "**#{label}**" } do |b|
      b.use :label_input
    end
  end

  def custom_wrapper_with_custom_label_component
    SimpleForm.build tag: :span, class: 'custom_wrapper' do |b|
      b.use :label_text
    end
  end

  def custom_wrapper_with_html5_components
    SimpleForm.build tag: :span, class: 'custom_wrapper' do |b|
      b.use :label_text
    end
  end

  def custom_wrapper_with_required_input
    SimpleForm.build tag: :span, class: 'custom_wrapper' do |b|
      b.use :html5
      b.use :input, required: true
    end
  end

  def custom_form_for(object, *args, &block)
    simple_form_for(object, *args, { builder: CustomFormBuilder }, &block)
  end

  def custom_mapping_form_for(object, *args, &block)
    simple_form_for(object, *args, { builder: CustomMapTypeFormBuilder }, &block)
  end

  def with_concat_form_for(*args, &block)
    concat simple_form_for(*args, &(block || proc {}))
  end

  def with_concat_fields_for(*args, &block)
    concat simple_fields_for(*args, &block)
  end

  def with_concat_custom_form_for(*args, &block)
    concat custom_form_for(*args, &block)
  end

  def with_concat_custom_mapping_form_for(*args, &block)
    concat custom_mapping_form_for(*args, &block)
  end

  def with_form_for(object, *args, &block)
    with_concat_form_for(object) do |f|
      f.input(*args, &block)
    end
  end

  def with_input_for(object, attribute_name, type, options = {})
    with_concat_form_for(object) do |f|
      f.input(attribute_name, options.merge(as: type))
    end
  end
end

class CustomFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, *args, &block)
    super(attribute_name, *args, { input_html: { class: 'custom' } }, &block)
  end
end

class CustomMapTypeFormBuilder < SimpleForm::FormBuilder
  map_type :custom_type, to: SimpleForm::Inputs::StringInput
end
