# frozen_string_literal: true

# == Schema Information
#
# Table name: local_preview_cards
#
#  id                :bigint(8)        not null, primary key
#  status_id         :bigint(8)        not null
#  target_status_id  :bigint(8)
#  target_account_id :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class LocalPreviewCard < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include InstanceHelper
  include AccountsHelper
  include StatusesHelper

  belongs_to :status
  belongs_to :target_status, class_name: 'Status', optional: true
  belongs_to :target_account, class_name: 'Account', optional: true

  def url
    ActivityPub::TagManager.instance.url_for(object)
  end

  def embed_url
    '' # TODO: audio/video uploads?
  end

  alias original_url url

  def title
    account = object.is_a?(Account) ? object : object.account
    "#{display_name(account)} (#{acct(account)})"
  end

  def provider_name
    site_title
  end

  def provider_url
    ''
  end

  def author_name
    ''
  end

  def author_url
    ''
  end

  def description
    if object.is_a?(Account)
      account_description(object)
    elsif object.is_a?(Status)
      status_description(object)
    end
  end

  def type
    'link'
  end

  def link_type
    object.is_a?(Status) ? 'article' : 'unknown'
  end

  def html
    ''
  end

  def published_at
    nil
  end

  def max_score
    nil
  end

  def max_score_at
    nil
  end

  def trendable
    false
  end

  def image_description
    if object.is_a?(Account)
      ''
    elsif object.is_a?(Status)
      status_media&.description.presence || ''
    end
  end

  def width
    if object.is_a?(Account)
      400
    elsif object.is_a?(Status)
      if status_media&.image? && status_media.file.meta.present?
        status_media.file.meta.dig('original', 'width')
      else
        0 # TODO
      end
    end
  end

  def height
    if object.is_a?(Account)
      400
    elsif object.is_a?(Status)
      if status_media&.image? && status_media.file.meta.present?
        status_media.file.meta.dig('original', 'height')
      else
        0 # TODO
      end
    end
  end

  def blurhash
    if object.is_a?(Account)
      nil # TODO
    elsif object.is_a?(Status)
      status_media&.blurhash
    end
  end

  def image
    if object.is_a?(Account)
      object.avatar
    elsif object.is_a?(Status)
      status_media&.thumbnail
    end
  end

  def image?
    image.present?
  end

  def language
    nil # TODO
  end

  private

  def object
    target_status || target_account
  end

  def status_media
    object.ordered_media_attachments.first
  end
end
