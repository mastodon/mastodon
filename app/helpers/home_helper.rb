# frozen_string_literal: true

module HomeHelper
  def default_props
    {
      locale: I18n.locale,
    }
  end

  def preferred_avatar(account)
    current_account&.user&.setting_auto_play_gif ? account.avatar_original_url : account.avatar_static_url
  end

  def obscured_counter(count)
    if count <= 0
      '0'
    elsif count == 1
      '1'
    else
      '1+'
    end
  end

  def custom_field_classes(field)
    if field.verified?
      'verified'
    else
      'emojify'
    end
  end

  def sign_up_message
    if closed_registrations?
      t('auth.registration_closed', instance: site_hostname)
    elsif open_registrations?
      t('auth.register')
    elsif approved_registrations?
      t('auth.apply_for_account')
    end
  end
end
