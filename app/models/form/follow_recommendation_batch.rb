# frozen_string_literal: true

class Form::FollowRecommendationBatch < Form::BaseBatch
  attr_accessor :account_ids

  def save
    case action
    when 'suppress_follow_recommendation'
      suppress!
    when 'unsuppress_follow_recommendation'
      unsuppress!
    end
  end

  def persisted?
    true
  end

  private

  def suppress!
    authorize(:follow_recommendation, :suppress?)

    accounts.find_each do |account|
      FollowRecommendationSuppression.create(account: account)
    end
  end

  def unsuppress!
    authorize(:follow_recommendation, :unsuppress?)

    FollowRecommendationSuppression.where(account_id: account_ids).destroy_all
  end

  def accounts
    Account.where(id: account_ids)
  end
end
