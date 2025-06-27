# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkMailer do
  shared_examples 'optional bulk mailer settings' do
    context 'when no optional bulk mailer settings are present' do
      it 'does not include delivery method options' do
        expect(mail.message.delivery_method.settings).to be_empty
      end
    end

    context 'when optional bulk mailer settings are present' do
      let(:smtp_settings) do
        {
          address: 'localhost',
          port: 25,
          authentication: 'none',
        }
      end

      before do
        Rails.configuration.x.email ||= ActiveSupport::OrderedOptions.new
        Rails.configuration.x.email.update({ bulk_mail: { smtp_settings: } })
      end

      after do
        Rails.configuration.x.email = nil
      end

      it 'uses the bulk mailer settings' do
        expect(mail.message.delivery_method.settings).to eq({
          address: 'localhost',
          port: 25,
          authentication: nil,
          enable_starttls: nil,
          enable_starttls_auto: true,
        })
      end
    end
  end

  let(:receiver) { Fabricate(:user) }

  describe '#terms_of_service_changed' do
    let(:mail) { described_class.terms_of_service_changed(receiver, terms) }
    let(:terms) { Fabricate :terms_of_service }

    it_behaves_like 'optional bulk mailer settings'

    it 'renders terms_of_service_changed mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('bulk_mailer.terms_of_service_changed.subject')))
        .and(have_body_text(I18n.t('bulk_mailer.terms_of_service_changed.changelog')))
    end
  end

  describe '#announcement_published' do
    let(:mail) { described_class.announcement_published(receiver, announcement) }
    let(:announcement) { Fabricate :announcement }

    it_behaves_like 'optional bulk mailer settings'

    it 'renders announcement_published mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('bulk_mailer.announcement_published.subject')))
        .and(have_body_text(I18n.t('bulk_mailer.announcement_published.description', domain: local_domain_uri.host)))
    end
  end
end
