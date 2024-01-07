# frozen_string_literal: true

require 'rails_helper'

describe BackupMailer do
  let(:user) { Fabricate(:user) }

  describe '#ready' do
    let(:backup) { Fabricate(:backup) }
    let(:mail) { described_class.with(user: user, backup: backup).ready }

    it 'renders backup ready email' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('user_mailer.backup_ready.subject')))
        .and(have_body_text(I18n.t('user_mailer.backup_ready.title')))
        .and(have_body_text(I18n.t('user_mailer.backup_ready.explanation')))
    end
  end
end
