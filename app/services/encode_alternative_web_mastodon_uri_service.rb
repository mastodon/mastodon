# frozen_string_literal: true

class EncodeAlternativeWebMastodonURIService < BaseService
  def call(controller, query_values)
    return nil if query_values['web'].present?

    case controller
    when 'authorize_follows'
      uri = Addressable::URI.parse(query_values['acct'])
      uri.scheme = 'acct' unless uri.path && %w(http https).include?(uri.scheme)

      Addressable::URI.new(
        scheme: 'web+mastodon',
        host: 'follow',
        query_values: { uri: uri }
      )

    when 'shares'
      Addressable::URI.new(
        scheme: 'web+mastodon',
        host: 'share',
        query_values: { text: query_values['text'] }
      )
    end
  end
end
