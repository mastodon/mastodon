# frozen_string_literal: true
module SimpleForm
  module Inputs
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :BlockInput
    autoload :BooleanInput
    autoload :CollectionCheckBoxesInput
    autoload :CollectionInput
    autoload :CollectionRadioButtonsInput
    autoload :CollectionSelectInput
    autoload :DateTimeInput
    autoload :FileInput
    autoload :GroupedCollectionSelectInput
    autoload :HiddenInput
    autoload :NumericInput
    autoload :PasswordInput
    autoload :PriorityInput
    autoload :RangeInput
    autoload :StringInput
    autoload :TextInput
  end
end
