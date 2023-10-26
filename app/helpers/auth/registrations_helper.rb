# frozen_string_literal: true

module Auth::RegistrationsHelper
  def registrations_new_password_input_html
    simple_form_aria_label('password')
      .merge(autocomplete_new_password_options)
      .merge(password_length_options)
  end

  def registrations_new_password_confirmation_input_html
    simple_form_aria_label('confirm_password')
      .merge(autocomplete_new_password_options)
  end

  def registrations_edit_password_input_html
    simple_form_aria_label('new_password')
      .merge(autocomplete_new_password_options)
      .merge(password_length_options)
  end

  def registrations_edit_password_confirmation_input_html
    simple_form_aria_label('confirm_new_password')
      .merge(autocomplete_new_password_options)
  end

  private

  def simple_form_aria_label(value)
    { 'aria-label': t("simple_form.labels.defaults.#{value}") }
  end

  def password_length_options
    {
      minlength: min_password_length,
      maxlength: max_password_length,
    }
  end

  def autocomplete_new_password_options
    { autocomplete: 'new-password' }
  end

  def min_password_length
    User.password_length.first
  end

  def max_password_length
    User.password_length.last
  end
end
