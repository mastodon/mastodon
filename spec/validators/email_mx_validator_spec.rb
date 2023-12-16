# frozen_string_literal: true

require 'rails_helper'

describe EmailMxValidator do
  describe '#validate' do
    let(:user) { double(email: 'foo@example.com', sign_up_ip: '1.2.3.4', errors: double(add: nil)) }

    context 'for an e-mail domain that is explicitly allowed' do
      around do |block|
        tmp = Rails.configuration.x.email_domains_whitelist
        Rails.configuration.x.email_domains_whitelist = 'example.com'
        block.call
        Rails.configuration.x.email_domains_whitelist = tmp
      end

      it 'does not add errors if there are no DNS records' do
        resolver = double

        allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([])
        allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
        allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::AAAA).and_return([])
        allow(resolver).to receive(:timeouts=).and_return(nil)
        allow(Resolv::DNS).to receive(:open).and_yield(resolver)

        subject.validate(user)
        expect(user.errors).to_not have_received(:add)
      end
    end

    it 'adds no error if there are DNS records for the e-mail domain' do
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([Resolv::DNS::Resource::IN::A.new('192.0.2.42')])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::AAAA).and_return([])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).not_to have_received(:add)
    end

    it 'adds an error if the email domain name contains empty labels' do
      resolver = double

      allow(resolver).to receive(:getresources).with('example..com', Resolv::DNS::Resource::IN::MX).and_return([])
      allow(resolver).to receive(:getresources).with('example..com', Resolv::DNS::Resource::IN::A).and_return([Resolv::DNS::Resource::IN::A.new('192.0.2.42')])
      allow(resolver).to receive(:getresources).with('example..com', Resolv::DNS::Resource::IN::AAAA).and_return([])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      user = double(email: 'foo@example..com', sign_up_ip: '1.2.3.4', errors: double(add: nil))
      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if there are no DNS records for the e-mail domain' do
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::AAAA).and_return([])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if a MX record does not lead to an IP' do
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([double(exchange: 'mail.example.com')])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::AAAA).and_return([])
      allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::AAAA).and_return([])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if the MX record is blacklisted' do
      EmailDomainBlock.create!(domain: 'mail.example.com')
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([double(exchange: 'mail.example.com')])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::AAAA).and_return([])
      allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::A).and_return([double(address: '2.3.4.5')])
      allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::AAAA).and_return([double(address: 'fd00::2')])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end
  end
end
