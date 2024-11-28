# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailMxValidator do
  describe '#validate' do
    let(:user) { instance_double(User, email: 'foo@example.com', sign_up_ip: '1.2.3.4', errors: instance_double(ActiveModel::Errors, add: nil)) }
    let(:resolv_dns_double) { instance_double(Resolv::DNS) }

    context 'with an e-mail domain that is explicitly allowed' do
      around do |block|
        tmp = Rails.configuration.x.email_domains_allowlist
        Rails.configuration.x.email_domains_allowlist = 'example.com'
        block.call
        Rails.configuration.x.email_domains_allowlist = tmp
      end

      it 'does not add errors if there are no DNS records' do
        configure_resolver('example.com')

        subject.validate(user)
        expect(user.errors).to_not have_received(:add)
      end
    end

    it 'adds no error if there are DNS records for the e-mail domain' do
      configure_resolver('example.com', a: resolv_double_a('192.0.2.42'))

      subject.validate(user)
      expect(user.errors).to_not have_received(:add)
    end

    it 'adds an error if the TagManager fails to normalize domain' do
      double = instance_double(TagManager)
      allow(TagManager).to receive(:instance).and_return(double)
      allow(double).to receive(:normalize_domain).with('example.com').and_raise(Addressable::URI::InvalidURIError)

      user = instance_double(User, email: 'foo@example.com', errors: instance_double(ActiveModel::Errors, add: nil))
      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if the domain email portion is blank' do
      user = instance_double(User, email: 'foo@', errors: instance_double(ActiveModel::Errors, add: nil))
      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if the email domain name contains empty labels' do
      configure_resolver('example..com', a: resolv_double_a('192.0.2.42'))

      user = instance_double(User, email: 'foo@example..com', sign_up_ip: '1.2.3.4', errors: instance_double(ActiveModel::Errors, add: nil))
      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if there are no DNS records for the e-mail domain' do
      configure_resolver('example.com')

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if a MX record does not lead to an IP' do
      configure_resolver('example.com', mx: resolv_double_mx('mail.example.com'))
      configure_resolver('mail.example.com')

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if the MX record has an email domain block' do
      EmailDomainBlock.create!(domain: 'mail.example.com')

      configure_resolver(
        'example.com',
        mx: resolv_double_mx('mail.example.com')
      )
      configure_resolver(
        'mail.example.com',
        a: instance_double(Resolv::DNS::Resource::IN::A, address: '2.3.4.5'),
        aaaa: instance_double(Resolv::DNS::Resource::IN::AAAA, address: 'fd00::2')
      )

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end
  end

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
