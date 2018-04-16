# frozen_string_literal: true
module SimpleForm
  # Helpers are made of several helpers that cannot be turned on automatically.
  # For instance, disabled cannot be turned on automatically, it requires the
  # user to explicitly pass the option disabled: true so it may work.
  module Helpers
    autoload :Autofocus,  'simple_form/helpers/autofocus'
    autoload :Disabled,   'simple_form/helpers/disabled'
    autoload :Readonly,   'simple_form/helpers/readonly'
    autoload :Required,   'simple_form/helpers/required'
    autoload :Validators, 'simple_form/helpers/validators'
  end
end
