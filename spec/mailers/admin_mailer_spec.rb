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
      expect { mail.deliver }
        .to send_email(
          to: recipient.user_email,
          from: 'notifications@localhost',
          subject: I18n.t('admin_mailer.new_report.subject', instance: Rails.configuration.x.local_domain, id: report.id)
        )
      expect(mail.body)
        .to match('Mike,')
        .and match('John has reported Mike')
        .and match("View: #{admin_report_url(report)}")
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
      expect { mail.deliver }
        .to send_email(
          to: recipient.user_email,
          from: 'notifications@localhost',
          subject: I18n.t('admin_mailer.new_appeal.subject', instance: Rails.configuration.x.local_domain, username: appeal.account.username)
        )
      expect(mail.body)
        .to match("#{appeal.account.username} is appealing a moderation decision by #{appeal.strike.account.username}")
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
      expect { mail.deliver }
        .to send_email(
          to: recipient.user_email,
          from: 'notifications@localhost',
          subject: I18n.t('admin_mailer.new_pending_account.subject', instance: Rails.configuration.x.local_domain, username: user.account.username)
        )
      expect(mail.body)
        .to match('The details of the new account are below. You can approve or reject this application.')
    end
  end

  describe '.new_trends' do
    let(:recipient) { Fabricate(:account, username: 'Snurf') }
    let!(:link) { Fabricate(:preview_card, trendable: true, language: 'en') }
    let!(:status) { Fabricate(:status) }
    let!(:tag) { Fabricate(:tag, display_name: 'Test Tag') }
    let!(:other_tag) { Fabricate(:tag, display_name: 'Other Test Tag') }
    let(:mail) { described_class.with(recipient: recipient).new_trends([link], [tag, other_tag], [status]) }
    let(:other_tag_trend) { Fabricate(:tag_trend, tag: other_tag) }

    before do
      recipient.user.update(locale: :en)
      Fabricate(:status_trend, status: status, account: Fabricate(:account))
      Fabricate(:tag_trend, tag: tag)
      Fabricate(:preview_card_trend, preview_card: link)
    end

    it 'renders the email' do
      expect { mail.deliver }
        .to send_email(
          to: recipient.user_email,
          from: 'notifications@localhost',
          subject: I18n.t('admin_mailer.new_trends.subject', instance: Rails.configuration.x.local_domain)
        )
      expect(mail.body)
        .to match('The following items need a review before they can be displayed publicly')
        .and match(ActivityPub::TagManager.instance.url_for(status))
        .and match(link.title)
        .and match(tag.display_name)
    end

    context 'when between queueing and sending trends gets deleted' do
      before do
        recipient.user.update(locale: :en)
      end

      it 'sends the email when all but one trends were deleted without the respective tag or status or link' do
        other_tag_trend
        expect(mail.deliver_later!)
          .to be_successfully_enqueued

        TagTrend.delete_all
        StatusTrend.delete_all
        expect { mail.deliver }
          .to send_email(
            to: recipient.user_email,
            from: 'notifications@localhost',
            subject: I18n.t('admin_mailer.new_trends.subject', instance: Rails.configuration.x.local_domain)
          )
        expect(mail.body)
          .to have_text(/The following items need a review before they can be displayed publicly/)
          .and match(link.title)
          .and not_include(ActivityPub::TagManager.instance.url_for(status))
          .and not_include(tag.display_name)
      end

      it 'returns nil when no trends are present' do
        expect(mail.deliver_later!)
          .to be_successfully_enqueued

        TagTrend.delete_all
        StatusTrend.delete_all
        PreviewCardTrend.delete_all

        expect { mail.deliver }
          .to_not send_email
      end
    end
  end

  describe '.new_software_updates' do
    let(:recipient) { Fabricate(:account, username: 'Bob') }
    let(:mail) { described_class.with(recipient: recipient).new_software_updates }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect { mail.deliver }
        .to send_email(
          to: recipient.user_email,
          from: 'notifications@localhost',
          subject: I18n.t('admin_mailer.new_software_updates.subject', instance: Rails.configuration.x.local_domain)
        )
      expect(mail.body)
        .to match('New Mastodon versions have been released, you may want to update!')
    end
  end

  describe '.new_critical_software_updates' do
    let(:recipient) { Fabricate(:account, username: 'Bob') }
    let(:mail) { described_class.with(recipient: recipient).new_critical_software_updates }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect { mail.deliver }
        .to send_email(
          to: recipient.user_email,
          from: 'notifications@localhost',
          subject: I18n.t('admin_mailer.new_critical_software_updates.subject', instance: Rails.configuration.x.local_domain)
        )
      expect(mail.body)
        .to match('New critical versions of Mastodon have been released, you may want to update as soon as possible!')
      expect(mail)
        .to have_header('Importance', 'high')
        .and have_header('Priority', 'urgent')
        .and have_header('X-Priority', '1')
    end
  end

  describe '.auto_close_registrations' do
    let(:recipient) { Fabricate(:account, username: 'Bob') }
    let(:mail) { described_class.with(recipient: recipient).auto_close_registrations }

    before do
      recipient.user.update(locale: :en)
    end

    it 'renders the email' do
      expect { mail.deliver }
        .to send_email(
          to: recipient.user_email,
          from: 'notifications@localhost',
          subject: I18n.t('admin_mailer.auto_close_registrations.subject', instance: Rails.configuration.x.local_domain)
        )
      expect(mail.body)
        .to match('have been automatically switched')
    end
  end
end
