# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer do
  shared_examples 'delivery to memorialized user' do
    context 'when the account is memorialized' do
      before { receiver.account.update(memorial: true) }

      it 'does not deliver mail' do
        emails = capture_emails { mail.deliver_now }
        expect(emails).to be_empty
      end
    end
  end

  let(:receiver) { Fabricate(:user) }

  describe '#confirmation_instructions' do
    let(:mail) { described_class.confirmation_instructions(receiver, 'spec') }

    it 'renders confirmation instructions' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('devise.mailer.confirmation_instructions.title')))
        .and(have_body_text('spec'))
        .and(have_body_text(Rails.configuration.x.local_domain))
    end

    include_examples 'localized subject',
                     'devise.mailer.confirmation_instructions.subject',
                     instance: Rails.configuration.x.local_domain
    include_examples 'delivery to memorialized user'
  end

  describe '#reconfirmation_instructions' do
    let(:mail) { described_class.confirmation_instructions(receiver, 'spec') }

    it 'renders reconfirmation instructions' do
      receiver.update!(email: 'new-email@example.com', locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('devise.mailer.reconfirmation_instructions.title')))
        .and(have_body_text('spec'))
        .and(have_body_text(Rails.configuration.x.local_domain))
    end

    include_examples 'localized subject',
                     'devise.mailer.confirmation_instructions.subject',
                     instance: Rails.configuration.x.local_domain
    include_examples 'delivery to memorialized user'
  end

  describe '#reset_password_instructions' do
    let(:mail) { described_class.reset_password_instructions(receiver, 'spec') }

    it 'renders reset password instructions' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('devise.mailer.reset_password_instructions.title')))
        .and(have_body_text('spec'))
    end

    include_examples 'localized subject',
                     'devise.mailer.reset_password_instructions.subject'
    include_examples 'delivery to memorialized user'
  end

  describe '#password_change' do
    let(:mail) { described_class.password_change(receiver) }

    it 'renders password change notification' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('devise.mailer.password_change.title')))
    end

    include_examples 'localized subject',
                     'devise.mailer.password_change.subject'
    include_examples 'delivery to memorialized user'
  end

  describe '#email_changed' do
    let(:mail) { described_class.email_changed(receiver) }

    it 'renders email change notification' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('devise.mailer.email_changed.title')))
    end

    include_examples 'localized subject',
                     'devise.mailer.email_changed.subject'
    include_examples 'delivery to memorialized user'
  end

  describe '#warning' do
    let(:strike) { Fabricate(:account_warning, target_account: receiver.account, text: 'dont worry its just the testsuite', action: 'suspend') }
    let(:mail)   { described_class.warning(receiver, strike) }

    it 'renders warning notification' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('user_mailer.warning.title.suspend', acct: receiver.account.acct)))
        .and(have_body_text(strike.text))
    end
  end

  describe '#webauthn_credential_deleted' do
    let(:credential) { Fabricate(:webauthn_credential, user_id: receiver.id) }
    let(:mail) { described_class.webauthn_credential_deleted(receiver, credential) }

    it 'renders webauthn credential deleted notification' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('devise.mailer.webauthn_credential.deleted.title')))
    end

    include_examples 'localized subject',
                     'devise.mailer.webauthn_credential.deleted.subject'
    include_examples 'delivery to memorialized user'
  end

  describe '#suspicious_sign_in' do
    let(:ip) { '192.168.0.1' }
    let(:agent) { 'NCSA_Mosaic/2.0 (Windows 3.1)' }
    let(:timestamp) { Time.now.utc }
    let(:mail) { described_class.suspicious_sign_in(receiver, ip, agent, timestamp) }

    it 'renders suspicious sign in notification' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('user_mailer.suspicious_sign_in.explanation')))
    end

    include_examples 'localized subject',
                     'user_mailer.suspicious_sign_in.subject'
  end

  describe '#failed_2fa' do
    let(:ip) { '192.168.0.1' }
    let(:agent) { 'NCSA_Mosaic/2.0 (Windows 3.1)' }
    let(:timestamp) { Time.now.utc }
    let(:mail) { described_class.failed_2fa(receiver, ip, agent, timestamp) }

    it 'renders failed 2FA notification' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('user_mailer.failed_2fa.explanation')))
    end

    include_examples 'localized subject',
                     'user_mailer.failed_2fa.subject'
  end

  describe '#appeal_approved' do
    let(:appeal) { Fabricate(:appeal, account: receiver.account, approved_at: Time.now.utc) }
    let(:mail) { described_class.appeal_approved(receiver, appeal) }

    it 'renders appeal_approved notification' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('user_mailer.appeal_approved.subject', date: I18n.l(appeal.created_at))))
        .and(have_body_text(I18n.t('user_mailer.appeal_approved.title')))
    end
  end

  describe '#appeal_rejected' do
    let(:appeal) { Fabricate(:appeal, account: receiver.account, rejected_at: Time.now.utc) }
    let(:mail) { described_class.appeal_rejected(receiver, appeal) }

    it 'renders appeal_rejected notification' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('user_mailer.appeal_rejected.subject', date: I18n.l(appeal.created_at))))
        .and(have_body_text(I18n.t('user_mailer.appeal_rejected.title')))
    end
  end

  describe '#two_factor_enabled' do
    let(:mail) { described_class.two_factor_enabled(receiver) }

    it 'renders two_factor_enabled mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('devise.mailer.two_factor_enabled.subject')))
        .and(have_body_text(I18n.t('devise.mailer.two_factor_enabled.explanation')))
    end

    include_examples 'delivery to memorialized user'
  end

  describe '#two_factor_disabled' do
    let(:mail) { described_class.two_factor_disabled(receiver) }

    it 'renders two_factor_disabled mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('devise.mailer.two_factor_disabled.subject')))
        .and(have_body_text(I18n.t('devise.mailer.two_factor_disabled.explanation')))
    end

    include_examples 'delivery to memorialized user'
  end

  describe '#webauthn_enabled' do
    let(:mail) { described_class.webauthn_enabled(receiver) }

    it 'renders webauthn_enabled mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('devise.mailer.webauthn_enabled.subject')))
        .and(have_body_text(I18n.t('devise.mailer.webauthn_enabled.explanation')))
    end

    include_examples 'delivery to memorialized user'
  end

  describe '#webauthn_disabled' do
    let(:mail) { described_class.webauthn_disabled(receiver) }

    it 'renders webauthn_disabled mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('devise.mailer.webauthn_disabled.subject')))
        .and(have_body_text(I18n.t('devise.mailer.webauthn_disabled.explanation')))
    end

    include_examples 'delivery to memorialized user'
  end

  describe '#two_factor_recovery_codes_changed' do
    let(:mail) { described_class.two_factor_recovery_codes_changed(receiver) }

    it 'renders two_factor_recovery_codes_changed mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('devise.mailer.two_factor_recovery_codes_changed.subject')))
        .and(have_body_text(I18n.t('devise.mailer.two_factor_recovery_codes_changed.explanation')))
    end

    include_examples 'delivery to memorialized user'
  end

  describe '#webauthn_credential_added' do
    let(:credential) { Fabricate.build(:webauthn_credential) }
    let(:mail) { described_class.webauthn_credential_added(receiver, credential) }

    it 'renders webauthn_credential_added mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('devise.mailer.webauthn_credential.added.subject')))
        .and(have_body_text(I18n.t('devise.mailer.webauthn_credential.added.explanation')))
    end

    include_examples 'delivery to memorialized user'
  end

  describe '#welcome' do
    let(:mail) { described_class.welcome(receiver) }

    before do
      # This is a bit hacky and low-level but this allows stubbing trending tags
      tag_ids = Fabricate.times(5, :tag).pluck(:id)
      allow(Trends.tags).to receive(:query).and_return(instance_double(Trends::Query, allowed: Tag.where(id: tag_ids)))
    end

    it 'renders welcome mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('user_mailer.welcome.subject')))
        .and(have_body_text(I18n.t('user_mailer.welcome.explanation')))
    end

    include_examples 'delivery to memorialized user'
  end

  describe '#backup_ready' do
    let(:backup) { Fabricate(:backup) }
    let(:mail) { described_class.backup_ready(receiver, backup) }

    it 'renders backup_ready mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('user_mailer.backup_ready.subject')))
        .and(have_body_text(I18n.t('user_mailer.backup_ready.explanation')))
    end

    include_examples 'delivery to memorialized user'
  end

  describe '#terms_of_service_changed' do
    let(:terms) { Fabricate :terms_of_service }
    let(:mail) { described_class.terms_of_service_changed(receiver, terms) }

    it 'renders terms_of_service_changed mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('user_mailer.terms_of_service_changed.subject')))
        .and(have_body_text(I18n.t('user_mailer.terms_of_service_changed.changelog')))
    end
  end
end
