# frozen_string_literal: true

class StatusPolicy < ApplicationPolicy
  def show?
    return false if author.unavailable?

    if requires_mention?
      owned? || mention_exists?
    elsif private?
      owned? || following_author? || mention_exists?
    else
      current_account.nil? || (!author_blocking? && !author_blocking_domain?)
    end
  end

  # This is about requesting a quote post, not validating it
  def quote?
    show? && record.quote_policy_for_account(current_account) != :denied
  end

  def reblog?
    !requires_mention? && (!private? || owned?) && show? && !blocking_author?
  end

  def favourite?
    show? && !blocking_author?
  end

  def destroy?
    owned?
  end

  alias unreblog? destroy?

  def update?
    owned?
  end

  private

  def requires_mention?
    record.direct_visibility? || record.limited_visibility?
  end

  def owned?
    author.id == current_account&.id
  end

  def private?
    record.private_visibility?
  end

  def mention_exists?
    return false if current_account.nil?

    if record.mentions.loaded?
      record.mentions.any? { |mention| mention.account_id == current_account.id }
    else
      record.mentions.exists?(account: current_account)
    end
  end

  def author_blocking_domain?
    return false if current_account.nil? || current_account.domain.nil?

    author.domain_blocking?(current_account.domain)
  end

  def blocking_author?
    return false if current_account.nil?

    current_account.blocking?(author)
  end

  def author_blocking?
    return false if current_account.nil?

    current_account.blocked_by?(author)
  end

  def following_author?
    return false if current_account.nil?

    current_account.following?(author)
  end

  def author
    record.account
  end
end
