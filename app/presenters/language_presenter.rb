# frozen_string_literal: true

class LanguagePresenter < ActiveModelSerializers::Model
  attributes :code, :name

  def initialize(code)
    super()

    @code = code
    @item = LanguagesHelper::SUPPORTED_LOCALES[code]
  end

  def name
    @item[0]
  end
end
