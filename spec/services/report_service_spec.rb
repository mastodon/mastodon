# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportService, type: :service do
  subject { described_class.new }

  let(:source_account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }

  context 'with a local account' do
    it 'has a uri' do
      report = subject.call(source_account, target_account)
      expect(report.uri).to_not be_nil
    end
  end

  context 'with a remote account' do
    let(:remote_account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }
    let(:forward) { false }

    before do
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    end

    context 'when forward is true' do
      let(:forward) { true }

      it 'sends ActivityPub payload when forward is true' do
        subject.call(source_account, remote_account, forward: forward)
        expect(a_request(:post, 'http://example.com/inbox')).to have_been_made
      end

      it 'has an uri' do
        report = subject.call(source_account, remote_account, forward: forward)
        expect(report.uri).to_not be_nil
      end

      context 'when reporting a reply' do
        let(:remote_thread_account) { Fabricate(:account, domain: 'foo.com', protocol: :activitypub, inbox_url: 'http://foo.com/inbox') }
        let(:reported_status) { Fabricate(:status, account: remote_account, thread: Fabricate(:status, account: remote_thread_account)) }

        before do
          stub_request(:post, 'http://foo.com/inbox').to_return(status: 200)
        end

        context 'when forward_to_domains includes both the replied-to domain and the origin domain' do
          it 'sends ActivityPub payload to both the author of the replied-to post and the reported user' do
            subject.call(source_account, remote_account, status_ids: [reported_status.id], forward: forward, forward_to_domains: [remote_account.domain, remote_thread_account.domain])
            expect(a_request(:post, 'http://foo.com/inbox')).to have_been_made
            expect(a_request(:post, 'http://example.com/inbox')).to have_been_made
          end
        end

        context 'when forward_to_domains includes only the replied-to domain' do
          it 'sends ActivityPub payload only to the author of the replied-to post' do
            subject.call(source_account, remote_account, status_ids: [reported_status.id], forward: forward, forward_to_domains: [remote_thread_account.domain])
            expect(a_request(:post, 'http://foo.com/inbox')).to have_been_made
            expect(a_request(:post, 'http://example.com/inbox')).to_not have_been_made
          end
        end

        context 'when forward_to_domains does not include the replied-to domain' do
          it 'does not send ActivityPub payload to the author of the replied-to post' do
            subject.call(source_account, remote_account, status_ids: [reported_status.id], forward: forward)
            expect(a_request(:post, 'http://foo.com/inbox')).to_not have_been_made
          end
        end
      end
    end

    context 'when forward is false' do
      it 'does not send anything' do
        subject.call(source_account, remote_account, forward: forward)
        expect(a_request(:post, 'http://example.com/inbox')).to_not have_been_made
      end
    end
  end

  context 'when the reported status is a DM' do
    subject do
      -> { described_class.new.call(source_account, target_account, status_ids: [status.id]) }
    end

    let(:status) { Fabricate(:status, account: target_account, visibility: :direct) }

    context 'when it is addressed to the reporter' do
      before do
        status.mentions.create(account: source_account)
      end

      it 'creates a report' do
        expect { subject.call }.to change { target_account.targeted_reports.count }.from(0).to(1)
      end

      it 'attaches the DM to the report' do
        subject.call
        expect(target_account.targeted_reports.pluck(:status_ids)).to eq [[status.id]]
      end
    end

    context 'when it is not addressed to the reporter' do
      it 'errors out' do
        expect { subject.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the reporter is remote' do
      let(:source_account) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/users/1') }

      context 'when it is addressed to the reporter' do
        before do
          status.mentions.create(account: source_account)
        end

        it 'creates a report' do
          expect { subject.call }.to change { target_account.targeted_reports.count }.from(0).to(1)
        end

        it 'attaches the DM to the report' do
          subject.call
          expect(target_account.targeted_reports.pluck(:status_ids)).to eq [[status.id]]
        end
      end

      context 'when it is not addressed to the reporter' do
        it 'does not add the DM to the report' do
          subject.call
          expect(target_account.targeted_reports.pluck(:status_ids)).to eq [[]]
        end
      end
    end
  end

  context 'when other reports already exist for the same target' do
    subject do
      -> {  described_class.new.call(source_account, target_account) }
    end

    let!(:other_report) { Fabricate(:report, target_account: target_account) }

    before do
      ActionMailer::Base.deliveries.clear
      source_account.user.settings['notification_emails.report'] = true
      source_account.user.save
    end

    it 'does not send an e-mail' do
      expect { subject.call }.to_not change(ActionMailer::Base.deliveries, :count).from(0)
    end
  end
end
