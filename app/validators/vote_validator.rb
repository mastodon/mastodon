# frozen_string_literal: true

class VoteValidator < ActiveModel::Validator
  def validate(vote)
    vote.errors.add(:base, I18n.t('polls.errors.expired')) if vote.poll_expired?

    vote.errors.add(:base, I18n.t('polls.errors.invalid_choice')) if invalid_choice?(vote)

    if vote.poll_multiple? && already_voted_for_same_choice_on_multiple_poll?(vote)
      vote.errors.add(:base, I18n.t('polls.errors.already_voted'))
    elsif !vote.poll_multiple? && already_voted_on_non_multiple_poll?(vote)
      vote.errors.add(:base, I18n.t('polls.errors.already_voted'))
    end
  end

  private

  def invalid_choice?(vote)
    vote.choice.negative? || vote.choice >= vote.poll.options.size
  end

  def already_voted_for_same_choice_on_multiple_poll?(vote)
    if vote.persisted?
      account_votes_on_same_poll(vote).where(choice: vote.choice).where.not(poll_votes: { id: vote }).exists?
    else
      account_votes_on_same_poll(vote).where(choice: vote.choice).exists?
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
