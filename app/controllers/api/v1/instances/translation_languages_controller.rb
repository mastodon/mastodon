# frozen_string_literal: true

class Api::V1::Instances::TranslationLanguagesController < Api::BaseController
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  before_action :set_languages

  def show
    expires_in 1.day, public: true
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
