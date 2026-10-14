# frozen_string_literal: true

Fabricator(:export_with_custom_filters, from: :account) do
  after_create do |account|
    filter = Fabricate(:custom_filter, account: account, phrase: 'foo')
    other_filter = Fabricate(:custom_filter, account: account, phrase: 'bar')

    Fabricate(:custom_filter_keyword, custom_filter: filter)
    Fabricate(:custom_filter_keyword, keyword: 'something', custom_filter: filter, whole_word: false)
    Fabricate(:custom_filter_keyword, custom_filter: other_filter)
    Fabricate(:custom_filter_keyword, keyword: 'something', custom_filter: other_filter, whole_word: false)
    Fabricate(:custom_filter_status, custom_filter: filter)
  end
end
