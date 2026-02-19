# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Measure::InstanceMediaAttachmentsMeasure do
  subject { described_class.new(start_at, end_at, params) }

  let(:domain) { 'example.com' }

  let(:start_at) { 2.days.ago }
  let(:end_at)   { Time.now.utc }

  let(:params) { ActionController::Parameters.new(domain: domain) }

  let(:remote_account) { Fabricate(:account, domain: domain) }
  let(:remote_account_on_subdomain) { Fabricate(:account, domain: "foo.#{domain}") }

  before do
    remote_account.media_attachments.create!(file: attachment_fixture('attachment.jpg'))
    remote_account_on_subdomain.media_attachments.create!(file: attachment_fixture('attachment.jpg'))
  end

  describe '#total' do
    context 'without include_subdomains' do
      it 'returns the expected number of accounts' do
        expected_total = remote_account.media_attachments.sum(:file_file_size) + remote_account.media_attachments.sum(:thumbnail_file_size)
        expect(subject.total).to eq expected_total
      end
    end

    context 'with include_subdomains' do
      let(:params) { ActionController::Parameters.new(domain: domain, include_subdomains: 'true') }

      it 'returns the expected number of accounts' do
        expected_total = [remote_account, remote_account_on_subdomain].sum do |account|
          account.media_attachments.sum(:file_file_size) + account.media_attachments.sum(:thumbnail_file_size)
        end

        expect(subject.total).to eq expected_total
      end
    end
  end

  describe '#data' do
    it 'returns correct media_attachments counts' do
      expect(subject.data.size)
        .to eq(3)
      expect(subject.data.map(&:symbolize_keys))
        .to contain_exactly(
          include(date: 2.days.ago.midnight.to_time, value: '0'),
          include(date: 1.day.ago.midnight.to_time, value: '0'),
          include(date: 0.days.ago.midnight.to_time, value: expected_domain_only_total.to_s)
        )
    end

    def expected_domain_only_total
      remote_account.media_attachments.sum(:file_file_size) + remote_account.media_attachments.sum(:thumbnail_file_size)
    end
  end
end
