# frozen_string_literal: true

class VoteValidator < ActiveModel::Validator
  def validate(vote)
    vote.errors.add(:base, I18n.t('polls.errors.expired')) if vote.poll_expired?
    vote.errors.add(:base, I18n.t('polls.errors.invalid_choice')) if invalid_choice?(vote)
    vote.errors.add(:base, I18n.t('polls.errors.self_vote')) if self_vote?(vote)

    vote.errors.add(:base, I18n.t('polls.errors.already_voted')) if additional_voting_not_allowed?(vote)
  end

  private

  def additional_voting_not_allowed?(vote)
    poll_multiple_and_already_voted?(vote) || poll_non_multiple_and_already_voted?(vote)
  end

  def poll_multiple_and_already_voted?(vote)
    vote.poll_multiple? && already_voted_for_same_choice_on_multiple_poll?(vote)
  end

  def poll_non_multiple_and_already_voted?(vote)
    !vote.poll_multiple? && already_voted_on_non_multiple_poll?(vote)
  end

  def invalid_choice?(vote)
    vote.choice.negative? || vote.choice >= vote.poll.options.size
  end

  def self_vote?(vote)
    vote.account_id == vote.poll.account_id
  end

  def already_voted_for_same_choice_on_multiple_poll?(vote)
    if vote.persisted?
      account_votes_on_same_poll(vote).where(choice: vote.choice).where.not(poll_votes: { id: vote }).exists?
    else
      account_votes_on_same_poll(vote).exists?(choice: vote.choice)
    end
  end

  def already_voted_on_non_multiple_poll?(vote)
    if vote.persisted?
      account_votes_on_same_poll(vote).where.not(poll_votes: { id: vote }).exists?
    else
      account_votes_on_same_poll(vote).exists?
    end
  end

  def account_votes_on_same_poll(vote)
    vote.poll.votes.where(account: vote.account)
  end
end
