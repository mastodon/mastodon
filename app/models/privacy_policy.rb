# frozen_string_literal: true

class PrivacyPolicy < ActiveModelSerializers::Model
  DEFAULT_PRIVACY_POLICY = Rails.root.join('config', 'templates', 'privacy-policy.md').read
  DEFAULT_UPDATED_AT = DateTime.new(2022, 10, 7).freeze

  attributes :updated_at, :text

  def self.current
    custom = Setting.find_by(var: 'site_terms')

    if custom&.value.present?
      new(text: custom.value, updated_at: custom.updated_at)
    else
      new(text: DEFAULT_PRIVACY_POLICY, updated_at: DEFAULT_UPDATED_AT)
    end
  end
end
