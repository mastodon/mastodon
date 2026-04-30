# frozen_string_literal: true

class AnnouncementFilter < BaseFilter
  KEYS = %i(
    published
    unpublished
  ).freeze

  IGNORED_PARAMS = %w(page).freeze

  def results
    scope = Announcement.unscoped

    params.each do |key, value|
      next if IGNORED_PARAMS.include?(key.to_s)

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope.chronological
  end

  private

  def scope_for(key, _value)
    case key.to_s
    when 'published'
      Announcement.published
    when 'unpublished'
      Announcement.unpublished
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end
end
