# frozen_string_literal: true

class BackupMailer < ApplicationMailer
  before_action :set_user
  before_action :set_backup

  default to: -> { @user.email }

  helper :routing

  def ready
    return unless @user.active_for_authentication?

    I18n.with_locale(user_locale_or_default) do
      # TODO: Restore `default_i18n_subject` after full mailer move
      mail subject: t('user_mailer.backup_ready.subject') # default_i18n_subject
    end
  end

  private

  def user_locale_or_default
    @user.locale.presence || I18n.default_locale
  end

  def set_user
    @user = params[:user]
  end

  def set_backup
    @backup = params[:backup]
  end
end
