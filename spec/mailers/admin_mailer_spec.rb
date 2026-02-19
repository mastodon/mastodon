# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminMailer do
  describe '.new_report' do
    let(:sender)    { Fabricate(:account, username: 'John') }
    let(:recipient) { Fabricate(:account, username: 'Mike') }
    let(:report)    { Fabricate(:report, account: sender, target_account: recipient) }
    let(:mail)      { described_class.with(recipient: recipient).new_report(report) }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(deliver_to(recipient.user_email))
        .and(deliver_from('notifications@localhost'))
        .and(have_subject(I18n.t('admin_mailer.new_report.subject', instance: Rails.configuration.x.local_domain, id: report.id)))
        .and(have_body_text("Mike,\r\n\r\nJohn has reported Mike\r\n\r\nView: #{admin_report_url(report)}\r\n"))
    end
  end

  describe '.new_appeal' do
    let(:appeal) { Fabricate(:appeal) }
    let(:recipient) { Fabricate(:account, username: 'Kurt') }
    let(:mail)      { described_class.with(recipient: recipient).new_appeal(appeal) }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(deliver_to(recipient.user_email))
        .and(deliver_from('notifications@localhost'))
        .and(have_subject(I18n.t('admin_mailer.new_appeal.subject', instance: Rails.configuration.x.local_domain, username: appeal.account.username)))
        .and(have_body_text("#{appeal.account.username} is appealing a moderation decision by #{appeal.strike.account.username}"))
    end
  end

  describe '.new_pending_account' do
    let(:recipient) { Fabricate(:account, username: 'Barklums') }
    let(:user) { Fabricate(:user) }
    let(:mail) { described_class.with(recipient: recipient).new_pending_account(user) }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(deliver_to(recipient.user_email))
        .and(deliver_from('notifications@localhost'))
        .and(have_subject(I18n.t('admin_mailer.new_pending_account.subject', instance: Rails.configuration.x.local_domain, username: user.account.username)))
        .and(have_body_text('The details of the new account are below. You can approve or reject this application.'))
    end
  end

  describe '.new_trends' do
    let(:recipient) { Fabricate(:account, username: 'Snurf') }
    let(:link) { Fabricate(:preview_card, trendable: true, language: 'en') }
    let(:status) { Fabricate(:status) }
    let(:tag) { Fabricate(:tag) }
    let(:mail) { described_class.with(recipient: recipient).new_trends([link], [tag], [status]) }

    before do
      PreviewCardTrend.create!(preview_card: link)
      StatusTrend.create!(status: status, account: Fabricate(:account))
      TagTrend.create!(tag: tag)
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(deliver_to(recipient.user_email))
        .and(deliver_from('notifications@localhost'))
        .and(have_subject(I18n.t('admin_mailer.new_trends.subject', instance: Rails.configuration.x.local_domain)))
        .and(have_body_text('The following items need a review before they can be displayed publicly'))
        .and(have_body_text(ActivityPub::TagManager.instance.url_for(status)))
        .and(have_body_text(link.title))
        .and(have_body_text(tag.display_name))
    end
  end

  describe '.new_software_updates' do
    let(:recipient) { Fabricate(:account, username: 'Bob') }
    let(:mail) { described_class.with(recipient: recipient).new_software_updates }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(deliver_to(recipient.user_email))
        .and(deliver_from('notifications@localhost'))
        .and(have_subject(I18n.t('admin_mailer.new_software_updates.subject', instance: Rails.configuration.x.local_domain)))
        .and(have_body_text('New Mastodon versions have been released, you may want to update!'))
    end
  end

  describe '.new_critical_software_updates' do
    let(:recipient) { Fabricate(:account, username: 'Bob') }
    let(:mail) { described_class.with(recipient: recipient).new_critical_software_updates }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(deliver_to(recipient.user_email))
        .and(deliver_from('notifications@localhost'))
        .and(have_subject(I18n.t('admin_mailer.new_critical_software_updates.subject', instance: Rails.configuration.x.local_domain)))
        .and(have_body_text('New critical versions of Mastodon have been released, you may want to update as soon as possible!'))
        .and(have_header('Importance', 'high'))
        .and(have_header('Priority', 'urgent'))
        .and(have_header('X-Priority', '1'))
    end
  end

  describe '.auto_close_registrations' do
    let(:recipient) { Fabricate(:account, username: 'Bob') }
    let(:mail) { described_class.with(recipient: recipient).auto_close_registrations }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect(mail)
        .to be_present
        .and(deliver_to(recipient.user_email))
        .and(deliver_from('notifications@localhost'))
        .and(have_subject(I18n.t('admin_mailer.auto_close_registrations.subject', instance: Rails.configuration.x.local_domain)))
        .and(have_body_text('have been automatically switched'))
    end
  end
end
