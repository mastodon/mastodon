# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoftwareUpdateCheckService do
  subject { described_class.new }

  shared_examples 'when the feature is enabled' do
    let(:full_update_check_url) { "#{update_check_url}?version=#{Mastodon::Version.to_s.split('+')[0]}" }

    let(:devops_role)     { Fabricate(:user_role, name: 'DevOps', permissions: UserRole::FLAGS[:view_devops]) }
    let(:owner_user)      { Fabricate(:owner_user) }
    let(:old_devops_user) { Fabricate(:user) }
    let(:none_user)       { Fabricate(:user, role: devops_role) }
    let(:patch_user)      { Fabricate(:user, role: devops_role) }
    let(:critical_user)   { Fabricate(:user, role: devops_role) }

    around do |example|
      queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test

      example.run

      ActiveJob::Base.queue_adapter = queue_adapter
    end

    before do
      Fabricate(:software_update, version: '3.5.0', type: 'major', urgent: false)
      Fabricate(:software_update, version: '42.13.12', type: 'major', urgent: false)
      Fabricate(:software_update, version: 'Malformed', type: 'major', urgent: false)

      owner_user.settings.update('notification_emails.software_updates': 'all')
      owner_user.save!

      old_devops_user.settings.update('notification_emails.software_updates': 'all')
      old_devops_user.save!

      none_user.settings.update('notification_emails.software_updates': 'none')
      none_user.save!

      patch_user.settings.update('notification_emails.software_updates': 'patch')
      patch_user.save!

      critical_user.settings.update('notification_emails.software_updates': 'critical')
      critical_user.save!
    end

    context 'when the update server errors out' do
      before do
        stub_request(:get, full_update_check_url).to_return(status: 404)
      end

      it 'deletes outdated update records but keeps valid update records' do
        expect { subject.call }.to change { SoftwareUpdate.pluck(:version).sort }.from(['3.5.0', '42.13.12', 'Malformed']).to(['42.13.12'])
      end
    end

    context 'when the server returns new versions' do
      let(:server_json) do
        {
          updatesAvailable: [
            {
              version: '4.2.1',
              urgent: false,
              type: 'patch',
              releaseNotes: 'https://github.com/mastodon/mastodon/releases/v4.2.1',
            },
            {
              version: '4.3.0',
              urgent: false,
              type: 'minor',
              releaseNotes: 'https://github.com/mastodon/mastodon/releases/v4.3.0',
            },
            {
              version: '5.0.0',
              urgent: false,
              type: 'minor',
              releaseNotes: 'https://github.com/mastodon/mastodon/releases/v5.0.0',
            },
          ],
        }
      end

      before do
        stub_request(:get, full_update_check_url).to_return(body: Oj.dump(server_json))
      end

      it 'updates the list of known updates' do
        expect { subject.call }.to change { SoftwareUpdate.pluck(:version).sort }.from(['3.5.0', '42.13.12', 'Malformed']).to(['4.2.1', '4.3.0', '5.0.0'])
      end

      context 'when no update is urgent' do
        it 'sends e-mail notifications according to settings', :aggregate_failures do
          expect { subject.call }.to have_enqueued_mail(AdminMailer, :new_software_updates)
            .with(hash_including(params: { recipient: owner_user.account })).once
            .and(have_enqueued_mail(AdminMailer, :new_software_updates).with(hash_including(params: { recipient: patch_user.account })).once)
            .and(have_enqueued_mail.at_most(2))
        end
      end

      context 'when an update is urgent' do
        let(:server_json) do
          {
            updatesAvailable: [
              {
                version: '5.0.0',
                urgent: true,
                type: 'minor',
                releaseNotes: 'https://github.com/mastodon/mastodon/releases/v5.0.0',
              },
            ],
          }
        end

        it 'sends e-mail notifications according to settings', :aggregate_failures do
          expect { subject.call }.to have_enqueued_mail(AdminMailer, :new_critical_software_updates)
            .with(hash_including(params: { recipient: owner_user.account })).once
            .and(have_enqueued_mail(AdminMailer, :new_critical_software_updates).with(hash_including(params: { recipient: patch_user.account })).once)
            .and(have_enqueued_mail(AdminMailer, :new_critical_software_updates).with(hash_including(params: { recipient: critical_user.account })).once)
            .and(have_enqueued_mail.at_most(3))
        end
      end
    end
  end

  context 'when update checking is disabled' do
    around do |example|
      original = Rails.configuration.x.mastodon.software_update_url
      Rails.configuration.x.mastodon.software_update_url = ''
      example.run
      Rails.configuration.x.mastodon.software_update_url = original
    end

    before do
      Fabricate(:software_update, version: '3.5.0', type: 'major', urgent: false)
    end

    it 'deletes outdated update records' do
      expect { subject.call }.to change(SoftwareUpdate, :count).from(1).to(0)
    end
  end

  context 'when using the default update checking API' do
    let(:update_check_url) { 'https://api.joinmastodon.org/update-check' }

    it_behaves_like 'when the feature is enabled'
  end

  context 'when using a custom update check URL' do
    let(:update_check_url) { 'https://api.example.com/update_check' }

    around do |example|
      original = Rails.configuration.x.mastodon.software_update_url
      Rails.configuration.x.mastodon.software_update_url = 'https://api.example.com/update_check'
      example.run
      Rails.configuration.x.mastodon.software_update_url = original
    end

    it_behaves_like 'when the feature is enabled'
  end
end
