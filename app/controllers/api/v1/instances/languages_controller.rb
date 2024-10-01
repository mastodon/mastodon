# frozen_string_literal: true

class Api::V1::Instances::LanguagesController < Api::V1::Instances::BaseController
  skip_around_action :set_locale

  before_action :set_languages

  def show
    cache_even_if_authenticated!
    render json: @languages, each_serializer: REST::LanguageSerializer
  end

  private

  def set_languages
    @languages = LanguagesHelper::SUPPORTED_LOCALES.keys.map { |code| LanguagePresenter.new(code) }
  end
end
