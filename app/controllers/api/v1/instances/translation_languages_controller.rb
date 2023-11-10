# frozen_string_literal: true

class Api::V1::Instances::TranslationLanguagesController < Api::V1::Instances::BaseController
  before_action :set_languages

  def show
    cache_even_if_authenticated!
    render json: @languages
  end

  private

  def set_languages
    if TranslationService.configured?
      @languages = Rails.cache.fetch('translation_service/languages', expires_in: 7.days, race_condition_ttl: 1.hour) { TranslationService.configured.languages }
      @languages['und'] = @languages.delete(nil) if @languages.key?(nil)
    else
      @languages = {}
    end
  end
end
