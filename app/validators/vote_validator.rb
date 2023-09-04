# frozen_string_literal: true

class VoteValidator < ActiveModel::Validator
  def validate(vote)
    vote.errors.add(:base, I18n.t('polls.errors.expired')) if vote.poll.expired?

    vote.errors.add(:base, I18n.t('polls.errors.invalid_choice')) if invalid_choice?(vote)

    if vote.poll.multiple? && vote.poll.votes.where(account: vote.account, choice: vote.choice).exists?
      vote.errors.add(:base, I18n.t('polls.errors.already_voted'))
    elsif !vote.poll.multiple? && vote.poll.votes.where(account: vote.account).exists?
      vote.errors.add(:base, I18n.t('polls.errors.already_voted'))
    end
  end

  private

  def invalid_choice?(vote)
    vote.choice.negative? || vote.choice >= vote.poll.options.size
  end
end
