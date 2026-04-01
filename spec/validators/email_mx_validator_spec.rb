# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailMxValidator do
  subject { record_class.new }

  context 'with no options' do
    let(:record_class) do
      Class.new do
        include ActiveModel::Validations

        def self.name = 'Record'

        attr_accessor :email

        validates :email, email_mx: true
      end
    end

    let(:user) { Fabricate.build :user, email: }
    let(:email) { 'foo@example.com' }
    let(:resolv_dns_double) { instance_double(Resolv::DNS) }

    context 'with an e-mail domain that is explicitly allowed' do
      around do |example|
        original = Rails.configuration.x.email_domains_allowlist
        Rails.configuration.x.email_domains_allowlist = 'example.com'
        example.run
        Rails.configuration.x.email_domains_allowlist = original
      end

      context 'when there are not DNS records' do
        before { configure_resolver('example.com') }

        it { is_expected.to allow_value(email).for(:email) }
      end
    end

    context 'when there are DNS records for the domain' do
      before { configure_resolver('example.com', a: resolv_double_a('192.0.2.42')) }

      it { is_expected.to allow_value(email).for(:email) }
    end

    context 'when the TagManager fails to normalize the domain' do
      before do
        allow(TagManager).to receive(:instance).and_return(tag_manage_double)
        allow(tag_manage_double).to receive(:normalize_domain).with('example.com').and_raise(Addressable::URI::InvalidURIError)
      end

      let(:tag_manage_double) { instance_double(TagManager) }

      it { is_expected.to_not allow_value(email).for(:email) }
    end

    context 'when the email portion is blank' do
      let(:email) { 'foo@' }

      it { is_expected.to_not allow_value(email).for(:email) }
    end

    context 'when the email domain contains empty labels' do
      let(:email) { 'foo@example..com' }

      before { configure_resolver('example..com', a: resolv_double_a('192.0.2.42')) }

      it { is_expected.to_not allow_value(email).for(:email) }
    end

    context 'when there are no DNS records for the email domain' do
      before { configure_resolver('example.com') }

      it { is_expected.to_not allow_value(email).for(:email) }
    end

    context 'when MX record does not lead to an IP' do
      before do
        configure_resolver('example.com', mx: resolv_double_mx('mail.example.com'))
        configure_resolver('mail.example.com')
      end

      it { is_expected.to_not allow_value(email).for(:email) }
    end

    context 'when the MX record has an email domain block' do
      before do
        Fabricate :email_domain_block, domain: 'mail.example.com'
        configure_resolver(
          'example.com',
          mx: resolv_double_mx('mail.example.com')
        )
        configure_resolver(
          'mail.example.com',
          a: instance_double(Resolv::DNS::Resource::IN::A, address: '2.3.4.5'),
          aaaa: instance_double(Resolv::DNS::Resource::IN::AAAA, address: 'fd00::2')
        )
      end

      it { is_expected.to_not allow_value(email).for(:email) }
    end
  end

  private

  def configure_resolver(domain, options = {})
    allow(resolv_dns_double)
      .to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::MX)
      .and_return(Array(options[:mx]))
    allow(resolv_dns_double)
      .to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::A)
      .and_return(Array(options[:a]))
    allow(resolv_dns_double)
      .to receive(:getresources)
      .with(domain, Resolv::DNS::Resource::IN::AAAA)
      .and_return(Array(options[:aaaa]))
    allow(resolv_dns_double)
      .to receive(:timeouts=)
      .and_return(nil)
    allow(Resolv::DNS)
      .to receive(:open)
      .and_yield(resolv_dns_double)
  end

  def resolv_double_mx(domain)
    instance_double(Resolv::DNS::Resource::MX, exchange: domain)
  end

  def resolv_double_a(domain)
    Resolv::DNS::Resource::IN::A.new(domain)
  end
end
