# frozen_string_literal: true

class VoteValidator < ActiveModel::Validator
  def validate(vote)
    vote.errors.add(:base, I18n.t('polls.errors.expired')) if vote.poll.expired?

    if vote.poll.multiple? && vote.poll.votes.where(account: vote.account, choice: vote.choice).exists?
      vote.errors.add(:base, I18n.t('polls.errors.already_voted'))
    elsif !vote.poll.multiple? && vote.poll.votes.where(account: vote.account).exists?
      vote.errors.add(:base, I18n.t('polls.errors.already_voted'))
    end
  end
end
