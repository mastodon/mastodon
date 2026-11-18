# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Instances' do
  let(:current_user) { Fabricate(:admin_user) }
  let(:domain) { 'example.com' }
  let(:tracker) { DeliveryFailureTracker.new(domain) }

  before do
    Fabricate(:account, domain: domain)
    Instance.refresh
    sign_in current_user
  end

  describe 'Viewing instances' do
    around do |example|
      default_per_page = Instance.default_per_page
      Instance.paginates_per 1
      example.run
    ensure
      Instance.paginates_per default_per_page
    end

    before do
      Fabricate(:account, domain: domain)
      Fabricate(:account, domain: 'less.popular')
      Instance.refresh
    end

    it 'paginates instances ordered by account count' do
      visit admin_instances_path

      expect(page)
        .to have_title(I18n.t('admin.instances.title'))
        .and have_css('.directory__tag', count: 1)
        .and have_link(href: admin_instance_path(domain))
        .and have_no_link(href: admin_instance_path('less.popular'))

      click_on I18n.t('pagination.next')

      expect(page)
        .to have_css('.directory__tag', count: 1)
        .and have_link(href: admin_instance_path('less.popular'))
        .and have_no_link(href: admin_instance_path(domain))
    end
  end

  describe 'Viewing an instance' do
    it 'shows the instance dashboard and empty audit log' do
      visit admin_instance_path(domain)

      expect(page)
        .to have_title(domain)
        .and have_css('p', text: I18n.t('admin.instances.totals_time_period_hint_html'))
        .and have_css('p', text: I18n.t('accounts.nothing_here'))
    end

    it 'shows only audit logs for the instance domain' do
      Fabricate(:action_log, account: current_user.account, action: 'create', target: Fabricate(:domain_block, domain: domain))
      Fabricate(:action_log, account: current_user.account, action: 'create', target: Fabricate(:domain_block, domain: 'other.example'))

      visit admin_instance_path(domain)

      expect(page)
        .to have_css('.log-entry', count: 1)
      within('.log-entry') do
        expect(page)
          .to have_text(domain)
          .and have_no_text('other.example')
      end
    end
  end

  describe 'Clearing delivery errors' do
    before { tracker.track_failure! }

    it 'clears recorded failures and updates the availability display' do
      visit admin_instance_path(domain)

      expect { click_on I18n.t('admin.instances.delivery.clear') }
        .to change(tracker, :days).from(1).to(0)

      expect(page)
        .to have_current_path(admin_instance_path(domain))
        .and have_text(I18n.t('admin.instances.availability.no_failures_recorded'))
        .and have_no_link(I18n.t('admin.instances.delivery.clear'))
    end
  end

  describe 'Restarting delivery' do
    before do
      tracker.track_failure!
      Fabricate(:unavailable_domain, domain: domain)
    end

    it 'marks the instance available again and clears recorded failures' do
      visit admin_instance_path(domain)

      expect { click_on I18n.t('admin.instances.delivery.restart') }
        .to change { UnavailableDomain.exists?(domain: domain) }.from(true).to(false)
        .and change(tracker, :days).from(1).to(0)

      expect(page)
        .to have_current_path(admin_instance_path(domain))
        .and have_text(I18n.t('admin.instances.availability.no_failures_recorded'))
        .and have_link(I18n.t('admin.instances.delivery.stop'))
    end
  end

  describe 'Stopping delivery' do
    it 'marks the instance unavailable and offers to restart delivery' do
      visit admin_instance_path(domain)

      expect { click_on I18n.t('admin.instances.delivery.stop') }
        .to change { UnavailableDomain.exists?(domain: domain) }.from(false).to(true)

      expect(page)
        .to have_current_path(admin_instance_path(domain))
        .and have_link(I18n.t('admin.instances.delivery.restart'))
        .and have_no_link(I18n.t('admin.instances.delivery.stop'))
    end
  end

  describe 'Purging an instance' do
    before { Fabricate(:unavailable_domain, domain: domain) }

    it 'queues a domain purge and returns to the instances list' do
      visit admin_instance_path(domain)

      expect { click_on I18n.t('admin.instances.purge') }
        .to change(Admin::DomainPurgeWorker.jobs, :size).by(1)

      expect(Admin::DomainPurgeWorker)
        .to have_enqueued_sidekiq_job(domain)
      expect(page)
        .to have_current_path(admin_instances_path)
        .and have_text(I18n.t('admin.instances.destroyed_msg', domain: domain))
    end
  end
end
