# frozen_string_literal: true

module ThemeHelper
  def theme_param
    params[:theme] == 'dark' ? 'dark' : 'light'
  end

  def theme_class_name
    "theme-#{theme_param}"
  end
end
