# frozen_string_literal: true

class Admin::ModerationSuggestionsController < Admin::BaseController
  before_action :set_moderation_suggestions, only: :index
  before_action :set_moderation_suggestion, only: [:destroy]

  def index
    authorize :moderation_suggestion, :index?
  end

  def destroy
    authorize @moderation_suggestion, :dismiss?

    # TODO: log?
    @moderation_suggestion.update!(state: :dismissed)

    redirect_to admin_moderation_suggestions_path, notice: I18n.t('admin.moderation_suggestions.destroyed_msg')
  end

  private

  def set_moderation_suggestions
    @moderation_suggestions = ModerationSuggestion.where(state: ['new', 'mailed']).order(id: :asc)
  end

  def set_moderation_suggestion
    @moderation_suggestion = ModerationSuggestion.find(params[:id])
  end
end
