# frozen_string_literal: true

require 'rails_helper'

describe UserMailer, type: :mailer do
  let(:receiver) { Fabricate(:user) }

  shared_examples 'localized subject' do |*args, **kwrest|
    it 'renders subject localized for the locale of the receiver' do
      locale = I18n.available_locales.sample
      receiver.update!(locale: locale)
      expect(mail.subject).to eq I18n.t(*args, **kwrest.merge(locale: locale))
    end

    it 'renders subject localized for the default locale if the locale of the receiver is unavailable' do
      receiver.update!(locale: nil)
      expect(mail.subject).to eq I18n.t(*args, **kwrest.merge(locale: I18n.default_locale))
    end
  end

  describe 'confirmation_instructions' do
    let(:mail) { UserMailer.confirmation_instructions(receiver, 'spec') }

    it 'renders confirmation instructions' do
      receiver.update!(locale: nil)
      expect(mail.body.encoded).to include I18n.t('devise.mailer.confirmation_instructions.title')
      expect(mail.body.encoded).to include 'spec'
      expect(mail.body.encoded).to include Rails.configuration.x.local_domain
    end

    include_examples 'localized subject',
                     'devise.mailer.confirmation_instructions.subject',
                     instance: Rails.configuration.x.local_domain
  end

  describe 'reconfirmation_instructions' do
    let(:mail) { UserMailer.confirmation_instructions(receiver, 'spec') }

    it 'renders reconfirmation instructions' do
      receiver.update!(email: 'new-email@example.com', locale: nil)
      expect(mail.body.encoded).to include I18n.t('devise.mailer.reconfirmation_instructions.title')
      expect(mail.body.encoded).to include 'spec'
      expect(mail.body.encoded).to include Rails.configuration.x.local_domain
      expect(mail.subject).to eq I18n.t('devise.mailer.reconfirmation_instructions.subject',
                                        instance: Rails.configuration.x.local_domain,
                                        locale: I18n.default_locale)
    end
  end

  describe 'reset_password_instructions' do
    let(:mail) { UserMailer.reset_password_instructions(receiver, 'spec') }

    it 'renders reset password instructions' do
      receiver.update!(locale: nil)
      expect(mail.body.encoded).to include I18n.t('devise.mailer.reset_password_instructions.title')
      expect(mail.body.encoded).to include 'spec'
    end

    include_examples 'localized subject',
                     'devise.mailer.reset_password_instructions.subject'
  end

  describe 'password_change' do
    let(:mail) { UserMailer.password_change(receiver) }

    it 'renders password change notification' do
      receiver.update!(locale: nil)
      expect(mail.body.encoded).to include I18n.t('devise.mailer.password_change.title')
    end

    include_examples 'localized subject',
                     'devise.mailer.password_change.subject'
  end

  describe 'email_changed' do
    let(:mail) { UserMailer.email_changed(receiver) }

    it 'renders email change notification' do
      receiver.update!(locale: nil)
      expect(mail.body.encoded).to include I18n.t('devise.mailer.email_changed.title')
    end

    include_examples 'localized subject',
                     'devise.mailer.email_changed.subject'
  end

  describe 'warning' do
    let(:strike) { Fabricate(:account_warning, target_account: receiver.account, text: 'dont worry its just the testsuite', action: 'suspend') }
    let(:mail)   { UserMailer.warning(receiver, strike) }

    it 'renders warning notification' do
      receiver.update!(locale: nil)
      expect(mail.body.encoded).to include I18n.t('user_mailer.warning.title.suspend', acct: receiver.account.acct)
      expect(mail.body.encoded).to include strike.text
    end
  end

  describe 'webauthn_credential_deleted' do
    let(:credential) { Fabricate(:webauthn_credential, user_id: receiver.id) }
    let(:mail) { UserMailer.webauthn_credential_deleted(receiver, credential) }

    it 'renders webauthn credential deleted notification' do
      receiver.update!(locale: nil)
      expect(mail.body.encoded).to include I18n.t('devise.mailer.webauthn_credential.deleted.title')
    end

    include_examples 'localized subject',
                     'devise.mailer.webauthn_credential.deleted.subject'
  end

  describe 'suspicious_sign_in' do
    let(:ip) { '192.168.0.1' }
    let(:agent) { 'NCSA_Mosaic/2.0 (Windows 3.1)' }
    let(:timestamp) { Time.now.utc }
    let(:mail) { UserMailer.suspicious_sign_in(receiver, ip, agent, timestamp) }

    it 'renders suspicious sign in notification' do
      receiver.update!(locale: nil)
      expect(mail.body.encoded).to include I18n.t('user_mailer.suspicious_sign_in.explanation')
    end

    include_examples 'localized subject',
                     'user_mailer.suspicious_sign_in.subject'
  end

  describe 'appeal_approved' do
    let(:appeal) { Fabricate(:appeal, account: receiver.account, approved_at: Time.now.utc) }
    let(:mail) { UserMailer.appeal_approved(receiver, appeal) }

    it 'renders appeal_approved notification' do
      expect(mail.subject).to eq I18n.t('user_mailer.appeal_approved.subject', date: I18n.l(appeal.created_at))
      expect(mail.body.encoded).to include I18n.t('user_mailer.appeal_approved.title')
    end
  end

  describe 'appeal_rejected' do
    let(:appeal) { Fabricate(:appeal, account: receiver.account, rejected_at: Time.now.utc) }
    let(:mail) { UserMailer.appeal_rejected(receiver, appeal) }

    it 'renders appeal_rejected notification' do
      expect(mail.subject).to eq I18n.t('user_mailer.appeal_rejected.subject', date: I18n.l(appeal.created_at))
      expect(mail.body.encoded).to include I18n.t('user_mailer.appeal_rejected.title')
    end
  end
end
