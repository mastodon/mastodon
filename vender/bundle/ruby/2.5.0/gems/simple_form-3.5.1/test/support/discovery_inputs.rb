# frozen_string_literal: true
class StringInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    "<section>#{super}</section>".html_safe
  end
end

class NumericInput < SimpleForm::Inputs::NumericInput
  def input(wrapper_options = nil)
    "<section>#{super}</section>".html_safe
  end
end

class CustomizedInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    "<section>#{super}</section>".html_safe
  end

  def input_method
    :text_field
  end
end

class DeprecatedInput < SimpleForm::Inputs::StringInput
  def input
    "<section>#{super}</section>".html_safe
  end

  def input_method
    :text_field
  end
end

class CollectionSelectInput < SimpleForm::Inputs::CollectionSelectInput
  def input_html_classes
    super.push('chosen')
  end
end

module CustomInputs
  class CustomizedInput < SimpleForm::Inputs::StringInput
    def input_html_classes
      super.push('customized-namespace-custom-input')
    end
  end

  class PasswordInput < SimpleForm::Inputs::PasswordInput
    def input_html_classes
      super.push('password-custom-input')
    end
  end

  class NumericInput < SimpleForm::Inputs::PasswordInput
    def input_html_classes
      super.push('numeric-custom-input')
    end
  end
end
