# frozen_string_literal: true
module SimpleForm
  # Components are a special type of helpers that can work on their own.
  # For example, by using a component, it will automatically change the
  # output under given circumstances without user input. For example,
  # the disabled helper always need a disabled: true option given
  # to the input in order to be enabled. On the other hand, things like
  # hints can generate output automatically by doing I18n lookups.
  module Components
    extend ActiveSupport::Autoload

    autoload :Errors
    autoload :Hints
    autoload :HTML5
    autoload :LabelInput
    autoload :Labels
    autoload :MinMax
    autoload :Maxlength
    autoload :Minlength
    autoload :Pattern
    autoload :Placeholders
    autoload :Readonly
  end
end
