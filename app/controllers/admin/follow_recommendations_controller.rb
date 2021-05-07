# frozen_string_literal: true

module Admin
  class FollowRecommendationsController < BaseController
    before_action :set_language

    def show
      authorize :follow_recommendation, :show?

      @form     = Form::AccountBatch.new
      @accounts = filtered_follow_recommendations
    end

    def update
      @form = Form::AccountBatch.new(form_account_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.save
    rescue ActionController::ParameterMissing
      # Do nothing
    ensure
      redirect_to admin_follow_recommendations_path(filter_params)
    end

    private

    def set_language
      @language = follow_recommendation_filter.language
    end

    def filtered_follow_recommendations
      follow_recommendation_filter.results
    end

    def follow_recommendation_filter
      @follow_recommendation_filter ||= FollowRecommendationFilter.new(filter_params)
    end

    def form_account_batch_params
      params.require(:form_account_batch).permit(:action, account_ids: [])
    end

    def filter_params
      params.slice(*FollowRecommendationFilter::KEYS).permit(*FollowRecommendationFilter::KEYS)
    end

    def action_from_button
      if params[:suppress]
        'suppress_follow_recommendation'
      elsif params[:unsuppress]
        'unsuppress_follow_recommendation'
      end
    end
  end
end
