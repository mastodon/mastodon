# frozen_string_literal: true

class Admin::FollowRecommendations::SuppressionsController < Admin::BaseController
  def create
    authorize :follow_recommendation, :suppress?

    form = Form::AccountBatch.new(current_account:, action: 'suppress_follow_recommendation', account_ids: [account_id])
    form.save

    redirect_to admin_account_path(account_id)
  end

  def destroy
    authorize :follow_recommendation, :unsuppress?

    form = Form::AccountBatch.new(current_account:, action: 'unsuppress_follow_recommendation', account_ids: [account_id])
    form.save

    redirect_to admin_account_path(account_id)
  end

  private

  def account_id
    params[:account_id]
  end
end
