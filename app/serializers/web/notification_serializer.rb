# frozen_string_literal: true

class Web::NotificationSerializer < ActiveModel::Serializer
  include RoutingHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  attributes :access_token, :preferred_locale, :notification_id,
             :notification_type, :icon, :title, :body

  def access_token
    current_push_subscription.associated_access_token
  end

  def preferred_locale
    current_push_subscription.associated_user&.locale || I18n.default_locale
  end

  def notification_id
    object.id
  end

  def notification_type
    object.type
  end

  def icon
    full_asset_url(object.from_account.avatar_static_url)
  end

  def title
    I18n.t("notification_mailer.#{object.type}.subject", name: object.from_account.display_name.presence || object.from_account.username)
  end

  def body
    str = strip_tags(object.target_status&.spoiler_text.presence || object.target_status&.text || object.from_account.note)
    truncate(HTMLEntities.new.decode(str.to_str), length: 140, escape: false) # Do not encode entities, since this value will not be used in HTML
  end
end
