# frozen_string_literal: true

class AccountSuggestions::Source
  def key
    raise NotImplementedError
  end

  def get(_account, **kwargs)
    raise NotImplementedError
  end

  def remove(_account, target_account_id)
    raise NotImplementedError
  end

  protected

  def as_ordered_suggestions(scope, ordered_list)
    return [] if ordered_list.empty?

    map = scope.index_by(&method(:to_ordered_list_key))

    ordered_list.map { |ordered_list_key| map[ordered_list_key] }.compact.map do |account|
      AccountSuggestions::Suggestion.new(
        account: account,
        source: key
      )
    end
  end

  def to_ordered_list_key(_account)
    raise NotImplementedError
  end
end
