# frozen_string_literal: true

require 'rails_helper'

describe EmailMxValidator do
  describe '#validate' do
    let(:user) { double(email: 'foo@example.com', errors: double(add: nil)) }

    it 'adds an error if there are no DNS records for the e-mail domain' do
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if a MX record exists but does not lead to an IP' do
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([double(exchange: 'mail.example.com')])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if the A record is blacklisted' do
      EmailDomainBlock.create!(domain: '1.2.3.4')
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([double(address: '1.2.3.4')])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if the MX record is blacklisted' do
      EmailDomainBlock.create!(domain: '2.3.4.5')
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([double(exchange: 'mail.example.com')])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::A).and_return([double(address: '2.3.4.5')])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end

    it 'adds an error if the MX hostname is blacklisted' do
      EmailDomainBlock.create!(domain: 'mail.example.com')
      resolver = double

      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::MX).and_return([double(exchange: 'mail.example.com')])
      allow(resolver).to receive(:getresources).with('example.com', Resolv::DNS::Resource::IN::A).and_return([])
      allow(resolver).to receive(:getresources).with('mail.example.com', Resolv::DNS::Resource::IN::A).and_return([double(address: '2.3.4.5')])
      allow(resolver).to receive(:timeouts=).and_return(nil)
      allow(Resolv::DNS).to receive(:open).and_yield(resolver)

      subject.validate(user)
      expect(user.errors).to have_received(:add)
    end
  end
end
