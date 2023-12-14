# frozen_string_literal: true

class PrivacyPolicy < ActiveModelSerializers::Model
  DEFAULT_PRIVACY_POLICY = <<~TXT.freeze
    This privacy policy describes how %<domain>s ("%<domain>s", "we", "us")
    collects, protects and uses the personally identifiable information you may
    provide through the %<domain>s website or its API. The policy also
    describes the choices available to you regarding our use of your personal
    information and how you can access and update this information. This policy
    does not apply to the practices of companies that %<domain>s does not own
    or control, or to individuals that %<domain>s does not employ or manage.

    #{Rails.root.join('config', 'templates', 'privacy-policy.md').read}
  TXT

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
