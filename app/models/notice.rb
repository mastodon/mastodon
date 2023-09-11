# frozen_string_literal: true

class Notice < ActiveModelSerializers::Model
  attributes :id, :icon, :title, :message, :actions

  # Notices a user has seen are stored as a bitmap in
  # `users.seen_notifications`.
  NOTICE_BIT_MAP = {
    mastodon_privacy_4_2: 1, # rubocop:disable Naming/VariableNumber
  }.freeze

  def dismiss_for_user!(user)
    user.update!(seen_notices: (user.seen_notices || 0) | NOTICE_BIT_MAP[id])
  end

  class Action < ActiveModelSerializers::Model
    attributes :label, :url
  end

  class << self
    include RoutingHelper

    def first_unseen(user)
      notice_key = NOTICE_BIT_MAP.find { |_, bit| ((user.seen_notices || 0) & bit).zero? }&.first

      send("#{notice_key}_notice") if notice_key.present?
    end

    def find(key)
      throw ActiveRecord::RecordNotFound unless NOTICE_BIT_MAP.key?(key.to_sym)

      send("#{key}_notice")
    end

    private

    def mastodon_privacy_4_2_notice
      new(
        id: :mastodon_privacy_4_2, # rubocop:disable Naming/VariableNumber
        icon: nil,
        title: I18n.t('notices.mastodon_privacy_4_2.title'),
        message: I18n.t('notices.mastodon_privacy_4_2.message'),
        actions: [
          Action.new(
            label: I18n.t('notices.mastodon_privacy_4_2.review'),
            url: settings_privacy_url
          ),
        ]
      )
    end
  end
end
