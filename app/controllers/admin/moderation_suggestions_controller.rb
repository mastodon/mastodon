# frozen_string_literal: true

class Admin::ModerationSuggestionsController < Admin::BaseController
  before_action :set_moderation_suggestions, only: :index

  def index
    authorize :moderation_suggestion, :index?
  end

  private

  def set_moderation_suggestions
    @moderation_suggestions = ModerationSuggestion.where(state: ['new', 'mailed']).order(id: :asc)
  end
end
