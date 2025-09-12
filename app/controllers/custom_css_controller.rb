# frozen_string_literal: true

class CustomCssController < PrimitiveController
  def show
    expires_in 1.month, public: true
    render content_type: 'text/css'
  end

  private

  def custom_css_styles
    Setting.custom_css
  end
  helper_method :custom_css_styles
end
